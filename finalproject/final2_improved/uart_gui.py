"""
UART GUI for sending an input value to the FPGA, receiving back the full
8-coefficient u[]/v[] ciphertext polynomials after each run, and encrypting
whole words one character at a time.

Requirements:
    pip install pyserial

Usage:
    1. Plug in your USB-to-serial adapter, wired to PMOD IO_0 (T2) for rx
       and the new tx pin per top.xdc -- it will show up as a COM port on
       Windows (e.g. COM4/COM5) or /dev/ttyUSB0 on Linux/Mac.
    2. Edit SERIAL_PORT below to match.
    3. Run: python uart_gui.py
    4. Type a value 0-255 and click Send. It goes out as a single byte and
       is encrypted as a whole (bit i of the byte -> ciphertext coefficient
       i -- see crypto_engine.v's full-byte encoding note), matching real
       Kyber's per-coefficient bit encoding. The OUT value in the received
       frame is the decoded byte -- it should equal what you sent almost
       always (~96.7% of the time at these toy parameters; an occasional
       wrong bit is expected real-LWE behavior, not a bug).
    5. A few tens of ms later, the FPGA sends back an 18-byte frame
       (0xFF sync + u[0..7] + v[0..7] + recovered message) which appears
       in the table below.
    6. To encrypt a whole word: type it in the "Word to encrypt" box and
       click Encrypt Word. Each character is sent as ONE byte (one FPGA
       run per character now, not per bit -- the full-byte encoding means
       a whole character's worth of message fits in a single run), waiting
       for that character's own reply frame before sending the next, then
       reassembling the decoded bytes back into text.

One serial connection is opened once at startup and shared: the Send
button writes to it, and a background thread continuously reads from it
looking for frames. That's the key change from the old version, which
opened/closed a fresh connection on every Send -- doing that here would
have meant missing or fighting over the FPGA's replies.
"""
import threading
import queue
import tkinter as tk
from tkinter import ttk, messagebox
import serial

SERIAL_PORT = "COM4"      # <-- change to your board's port
BAUD_RATE   = 9600        # <-- must match uart_rx.v's / uart_tx.v's BAUD_RATE parameter

SYNC_BYTE = 0xFF
FRAME_LEN = 17            # 8 bytes u[] + 8 bytes v[] + 1 byte recovered message (OUT)

# ---------------------------------------------------------------------
# Serial connection: opened once, shared between Send (main thread) and
# the reader thread below.
# ---------------------------------------------------------------------
try:
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
except serial.SerialException as e:
    ser = None
    _open_error = str(e)
else:
    _open_error = None

uv_queue = queue.Queue()
stop_event = threading.Event()
word_in_progress = threading.Event()   # True while _encrypt_word_worker owns the queue


def reader_thread():
    """Background thread: scans for the 0xFF sync byte, reads the
    following 17 bytes, and pushes (u_list, v_list, out) onto uv_queue."""
    if ser is None:
        return
    while not stop_event.is_set():
        b = ser.read(1)
        if not b:
            continue  # read timeout, loop back and check stop_event
        if b[0] != SYNC_BYTE:
            continue  # resync: keep scanning

        payload = b""
        while len(payload) < FRAME_LEN and not stop_event.is_set():
            chunk = ser.read(FRAME_LEN - len(payload))
            payload += chunk
        if len(payload) < FRAME_LEN:
            continue  # timed out mid-frame, drop it and resync

        u = list(payload[0:8])
        v = list(payload[8:16])
        out = payload[16]
        uv_queue.put((u, v, out))


def send_value():
    text = value_var.get().strip()

    if not text.isdigit():
        messagebox.showerror("Invalid input", "Enter a whole number.")
        return

    value = int(text)

    if not (0 <= value <= 255):
        messagebox.showerror("Out of range", "Value must be 0-255 (a full byte).")
        return

    if ser is None:
        messagebox.showerror("Serial error", _open_error)
        return

    try:
        ser.write(bytes([value]))
        status.set(f"Sent: {value}  (encrypted as a full byte; check OUT below -- should match)")
    except serial.SerialException as e:
        messagebox.showerror("Serial error", str(e))


def encrypt_word():
    word = word_var.get()

    if not word:
        messagebox.showerror("Invalid input", "Enter a word to encrypt.")
        return

    if ser is None:
        messagebox.showerror("Serial error", _open_error)
        return

    # Disable the button while a word is in flight, so a second click
    # can't interleave with this one and scramble the character sequence.
    word_button["state"] = "disabled"
    word_result.set("")
    word_status.set(f"Encrypting '{word}'... 0/{len(word)} characters")

    thread = threading.Thread(target=_encrypt_word_worker, args=(word,), daemon=True)
    thread.start()


def _encrypt_word_worker(word):
    """Runs in a background thread: sends one BYTE per character (each
    character's full 8 bits are encrypted together in a single FPGA run,
    thanks to the full-byte encoding), waiting for that character's own
    18-byte frame to come back before sending the next -- the FPGA
    processes one message at a time, so sending faster than it can finish
    would scramble which OUT byte belongs to which input character."""

    word_in_progress.set()   # tell poll_uv_queue to leave the queue alone

    # Drain any stale frames left over from earlier Send-button clicks,
    # so the first frame we read back is guaranteed to be this word's.
    while not uv_queue.empty():
        try:
            uv_queue.get_nowait()
        except queue.Empty:
            break

    decoded_chars = []
    for idx, ch in enumerate(word):
        byte = ord(ch) & 0xFF
        try:
            ser.write(bytes([byte]))
        except serial.SerialException as e:
            root.after(0, lambda e=e: messagebox.showerror("Serial error", str(e)))
            break

        try:
            u, v, out = uv_queue.get(timeout=1.0)
        except queue.Empty:
            root.after(0, lambda i=idx: word_status.set(
                f"Timed out waiting for character {i+1}/{len(word)} -- check connection/board."))
            break

        decoded_chars.append(chr(out))

        done_count = idx + 1
        root.after(0, lambda dc=done_count, n=len(word): word_status.set(
            f"Encrypting... {dc}/{n} characters"))

    recovered = "".join(decoded_chars)

    def finish():
        word_result.set(f"Recovered: {recovered!r}")
        word_button["state"] = "normal"
    root.after(0, finish)

    word_in_progress.clear()   # hand the queue back to poll_uv_queue


def poll_uv_queue():
    # Skip draining while a word job owns the queue, so it doesn't race
    # _encrypt_word_worker for the same frames.
    if not word_in_progress.is_set():
        try:
            while True:
                u, v, out = uv_queue.get_nowait()
                for i in range(8):
                    u_labels[i]["text"] = str(u[i])
                    v_labels[i]["text"] = str(v[i])
                out_label["text"] = str(out)
                uv_status.set(f"Last frame  u={u}  v={v}  OUT={out}")
        except queue.Empty:
            pass
    root.after(50, poll_uv_queue)


def on_close():
    stop_event.set()
    if ser is not None:
        ser.close()
    root.destroy()


root = tk.Tk()
root.title("PQC Engine - UART Input / Output")
root.geometry("580x420")

# ---- send section ----
tk.Label(root, text="Message value (0-255):").pack(pady=(15, 5))

value_var = tk.StringVar()
tk.Entry(root, textvariable=value_var, width=10, justify="center").pack()

tk.Button(root, text="Send", command=send_value, width=15).pack(pady=10)

status = tk.StringVar(value="Ready" if ser is not None else f"Could not open {SERIAL_PORT}: {_open_error}")
tk.Label(root, textvariable=status, fg="gray", wraplength=520).pack()

# ---- receive section ----
uv_frame = ttk.Frame(root, padding=(10, 15))
uv_frame.pack()

ttk.Label(uv_frame, text="u[i]", font=("Consolas", 11, "bold")).grid(row=0, column=0, sticky="w")
ttk.Label(uv_frame, text="v[i]", font=("Consolas", 11, "bold")).grid(row=1, column=0, sticky="w")

u_labels = []
v_labels = []
for i in range(8):
    ttk.Label(uv_frame, text=f"i={i}", font=("Consolas", 9)).grid(row=2, column=1 + i)

    lu = ttk.Label(uv_frame, text="--", width=4, font=("Consolas", 11))
    lu.grid(row=0, column=1 + i)
    u_labels.append(lu)

    lv = ttk.Label(uv_frame, text="--", width=4, font=("Consolas", 11))
    lv.grid(row=1, column=1 + i)
    v_labels.append(lv)

uv_status = tk.StringVar(value="Waiting for a frame...")
tk.Label(root, textvariable=uv_status, fg="gray", wraplength=520).pack()

out_frame = ttk.Frame(root, padding=(10, 5))
out_frame.pack()
ttk.Label(out_frame, text="OUT (recovered message):", font=("Consolas", 11, "bold")).grid(row=0, column=0)
out_label = ttk.Label(out_frame, text="--", width=4, font=("Consolas", 11))
out_label.grid(row=0, column=1)

# ---- word encryption section ----
# Encrypts a whole word by running the FPGA's full-byte encrypt/decrypt
# cycle once per character, waiting for each character's own reply frame
# before sending the next, then reassembling the decoded bytes back into
# text.
ttk.Separator(root, orient="horizontal").pack(fill="x", pady=(10, 5))

word_frame = ttk.Frame(root, padding=(10, 5))
word_frame.pack()

ttk.Label(word_frame, text="Word to encrypt:").grid(row=0, column=0, padx=(0, 8))
word_var = tk.StringVar()
ttk.Entry(word_frame, textvariable=word_var, width=20).grid(row=0, column=1)
word_button = ttk.Button(word_frame, text="Encrypt Word", command=encrypt_word)
word_button.grid(row=0, column=2, padx=(8, 0))

word_status = tk.StringVar(value="")
tk.Label(root, textvariable=word_status, fg="gray", wraplength=520).pack()

word_result = tk.StringVar(value="")
tk.Label(root, textvariable=word_result, font=("Consolas", 11, "bold"), wraplength=520).pack(pady=(0, 10))

# ---- start background reader, hook up close handler, start polling ----
reader = threading.Thread(target=reader_thread, daemon=True)
reader.start()

root.protocol("WM_DELETE_WINDOW", on_close)
root.after(50, poll_uv_queue)

root.mainloop()
