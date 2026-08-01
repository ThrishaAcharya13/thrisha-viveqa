## AT-STLN-ARTIX7-001 constraints for top.v
## Source: AT-STLN-ARTIX 7-001 Hardware Reference Manual, Rev 1.0
##
## NOTES / GAPS IN THE MANUAL (read before you synthesize):
##  - The manual's FT232H table (sec 4.1) only maps ADBUS0-3 to JTAG;
##    it does not document a UART RX/TX path from the FT232H to the FPGA.
##    Per your instruction, 'rx' is instead routed through PMOD IO_0 (T2)
##    to an EXTERNAL USB-to-serial adapter's TX line -- wire that up on
##    the breadboard/PMOD header, it is not an onboard USB-UART path.
##  - The manual has no general-purpose push-button pin table (only
##    BTN2/PROGRAM_B, a dedicated FPGA config pin -- do not repurpose it).
##    Per your instruction, rst/mode instead use two keypad keys (sec 3.5),
##    which on this board are individually pin-mapped (not row/col
##    scanned), so they work fine as simple GPIO buttons.

## ---------------- Clock ----------------
create_clock -period 41.667 -name sys_clk [get_ports clk]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports clk]

## ---------------- Reset / Mode (keypad keys '0' and '1') ----------------
## Active-low (10K pull-up, press pulls to GND) -- inverted in top.v.
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33 PULLUP true} [get_ports key0_n]
set_property -dict {PACKAGE_PIN F5  IOSTANDARD LVCMOS33 PULLUP true} [get_ports key1_n]

## ---------------- UART RX (via PMOD -> external USB-serial adapter) -----
## Wire the external adapter's TX pin to PMOD J16 pin IO_0.
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports rx]

## ---------------- UART TX (via PMOD -> external USB-serial adapter) -----
## TODO: pick the next free pin on the same PMOD J16 header (commonly
## IO_1, adjacent to IO_0/T2 above) from your board manual's PMOD pinout
## table, and put its package pin here. Wire it to the external adapter's
## RX line. Left unconstrained for now -- fill in before synthesis or
## Vivado will error out on an unconstrained port.
# set_property -dict {PACKAGE_PIN <FILL_IN> IOSTANDARD LVCMOS33} [get_ports tx]

## ---------------- User LEDs (Bank 35) ----------------
set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN A3  IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN B4  IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN E6  IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports {led[7]}]

## ---------------- 16x2 LCD (Bank 35) ----------------
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports lcd_rs]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports lcd_rw]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports lcd_e]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {lcd_d[0]}]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {lcd_d[1]}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {lcd_d[2]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {lcd_d[3]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {lcd_d[4]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {lcd_d[5]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {lcd_d[6]}]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {lcd_d[7]}]

## ---------------- False path on async reset/mode inputs ----------------
set_false_path -from [get_ports {key0_n key1_n}]
