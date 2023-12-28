# vaaman-ahb
## AHB BUS PROTOCOL IMPLEMENTATION IN VERILOG

### OVERVIEW 

This repository hosts a Verilog implementation of the Advanced High-performance Bus (AHB) protocol.

### IMPLEMENTATION DETAILS

1. Master - master_ahb module
   - This is the master interface of AHB which initiates the write or read transaction to its slaves.
   
   - Assumptions made for our implementation in the version 1 of the design are: 
      - The max hsize or the transfer size of the data is = 32,
      - The design only works for the incrementing burst but not for the wrapping burst,
      - The slave isn't introducing any wait states,
      - The slave's response to be always an Okay. 
      - Read and a write doesn't happen consecutively but only after again initiating the transaction.                     
      - Burst and single transfers can't happen continously in the current design.

2. Slave - sram_top module 
   -- This has ahb_slave_if and sram_core instantiated in it.

3. ahb_slave_if module 
   -- This is the slave interface of AHB which sends the write address and data received from the master 
   to the sram core and responds with the read data from sram_core to the master.

4. sram_core module 
   -- Based on the bank and the channel selected the data is written into the selected sram and read from 
   the selected sram through the instantiation of sram_bist module.   
   -- Instance 8 srams and each provides with BIST and DFT functions. 
   -- Bank0 comprises of sram0~sram3, and bank1 comprises of sram4~sram7. 
   -- In each bank, the sram control signals broadcast to each sram, and data
   written per byte into each sram in little-endian style.

5. sram_bist module 
   -- This module has RA1SH_v1 module and sram_bist_8kx8 modules instances.

6. RA1SH_v1 module
   -- Sram singleport high density 8k depth x 8bit width. 
   -- Checks for the chip select and write enable and does the read or write accordingly.

7. sram_bist_8kx8 module 
   -- This is the design for bist test and dft to check the sram functionality. 
