FPGA Implementation of a Simplified Lattice-Based Post-Quantum Cryptographic Encryption and Decryption Engine with NTT Acceleration
1. Project Overview:

This project implements a simplified lattice-based post-quantum cryptographic (PQC) encryption and decryption engine on an Artix-7 FPGA. The design uses the Number Theoretic Transform (NTT) to accelerate polynomial multiplication, which is the core operation in lattice-based cryptography. The system receives plaintext through UART, performs key generation, encryption and decryption in hardware, and displays the output via UART, LCD, and LEDs.

Objectives:

•	Implement a simplified lattice-based PQC algorithm on FPGA.

•	Accelerate polynomial multiplication using NTT. 

•	Perform hardware-based key generation, encryption, and decryption.

•	Demonstrate secure data transmission using FPGA. 
________________________________________

2. Design and Architecture:

System Architecture

PC GUI
   │
UART Receiver
   │
Crypto Engine
   │
NTT Accelerator
   │
Memory
   │
UART TX / LCD / LEDs

Main Components:

•	UART Receiver & Transmitter 

•	Crypto Engine (Key Generation, Encryption, Decryption) 

•	NTT Accelerator 

•	Memory Module 

•	LCD Display 

•	LED Status Indicators 
________________________________________

3. Implementation Approach:

-	Plaintext is sent from the PC through UART.
-	
-	The Crypto Engine generates the secret/public keys.
-	
-	NTT performs fast polynomial multiplication.
-	
-	Encryption is carried out using the generated keys.
-	 
-	The ciphertext is decrypted to recover the original message.
-	 
-	The decrypted message is displayed on the LCD, LEDs, and UART. 
________________________________________

4. Module Descriptions:

top.v	- Integrates all project modules.

crypto_engine.v -	Controls key generation, encryption, and decryption.

lfsr.v -	Generates pseudo-random values for keys.

bank_mem.v - Stores polynomial coefficients and intermediate data.

butterfly.v -	Performs Forward NTT butterfly operations.

inverse_butterfly.v -	Performs Inverse NTT butterfly operations.

mod_add.v -	Modular addition operation.

mod_sub.v -	Modular subtraction operation.

mod_mul.v -	Modular multiplication operation.

twiddle_rom.v -	Stores Forward NTT twiddle factors.

inverse_twiddle_rom.v -	Stores Inverse NTT twiddle factors.

address_generator.v -	Generates addresses for NTT stages.

twiddle_index.v -	Generates twiddle factor indices.

uart_rx.v -	Receives data from PC.

uart_tx.v -	Sends processed data back to PC.

lcd_display.v -	Displays messages on a 16×2 LCD.
________________________________________

5. Build and Run Instructions:

Requirements:

•	Xilinx Vivado 

•	Artix-7 FPGA Board 

•	Python UART GUI (or Serial Terminal) 

•	USB-UART connection 

Steps:

1.	Open the project in Vivado.
   
3.	Add all Verilog source files and constraints.
   
5.	Set top.v as the top module.
   
7.	Run Synthesis, Implementation, and Generate Bitstream.
   
9.	Program the FPGA.
    
11.	Open the UART GUI and send a plaintext character.
    
13.	Observe the encrypted/decrypted output on the UART, LCD, and LEDs.
     
________________________________________

6. Testing:

Test Procedure:

•	Send a plaintext character (e.g., A) through the UART GUI. 

•	Verify that the FPGA performs encryption and decryption. 

•	Confirm that the recovered plaintext matches the original input. 

•	Check the output on the UART terminal, LCD display, and LEDs. 
________________________________________

7. Applications:

•	Post-Quantum Cryptography 

•	Secure Embedded Systems 

•	IoT Security 

•	FPGA-Based Cryptographic Accelerators 

•	Secure Communication Systems 
________________________________________


8. Conclusion:

This project demonstrates a hardware implementation of a simplified lattice-based post-quantum cryptographic engine on an FPGA. By using an NTT accelerator, the design achieves efficient polynomial multiplication, enabling faster encryption and decryption. The modular architecture, UART interface, and LCD output make the system suitable for demonstrating quantum-resistant cryptography on FPGA hardware.

