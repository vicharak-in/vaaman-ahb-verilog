# vaaman-ahb

## AHB BUS PROTOCOL IMPLEMENTATION IN VERILOG

### OVERVIEW 

This repository hosts a Verilog implementation of the Advanced High-performance Bus (AHB) protocol.

### IMPLEMENTATION DETAILS

> Master - master_ahb module
   * This is the master interface of AHB which initiates the write or read transaction to its slaves.
     ![image](https://github.com/vicharak-in/vaaman-ahb-verilog/assets/102940423/3ce5a4f0-4bf2-4b85-8986-e8de30555711)

   
   * Assumptions made for our implementation in the version 1 of the design are: 
      * The max hsize or the transfer size of the data is = 32,
      * The design only works for the incrementing burst but not for the wrapping burst,
      * The slave isn't introducing any wait states,
      * The slave's response to be always an Okay. 
      * Read and a write doesn't happen consecutively but only after again initiating the transaction.                     
      * Burst and single transfers can't happen continously in the current design.


> Slave - sram_top module 
   * This has ahb_slave_if and sram_core instantiated in it.

> ahb_slave_if module 
   * This is the slave interface of AHB which sends the write address and data received from the master 
   to the sram core and responds with the read data from sram_core to the master.
     ![image](https://github.com/vicharak-in/vaaman-ahb-verilog/assets/102940423/534202e7-6b36-4753-aa8d-66457a12023b)



> sram_core module 
   * Based on the bank and the channel selected the data is written into the selected sram and read from 
   the selected sram through the instantiation of sram_bist module.   
   * Instance 8 srams and each provides with BIST and DFT functions. 
   * Bank0 comprises of sram0-sram3, and bank1 comprises of sram4-sram7. 
   * In each bank, the sram control signals broadcast to each sram, and data
   written per byte into each sram in little-endian style.
     ![image](https://github.com/vicharak-in/vaaman-ahb-verilog/assets/102940423/ae84d238-a164-479d-8d28-7906b383a7e6)


> sram_bist module 
   * This module has RA1SH_v1 module and sram_bist_8kx8 modules instances.
     ![image](https://github.com/vicharak-in/vaaman-ahb-verilog/assets/102940423/88940225-6f6e-4182-86bf-237d91c72457)



> RA1SH_v1 module
   * Sram singleport high density 8k depth x 8bit width. 
   * Checks for the chip select and write enable and does the read or write accordingly.
     ![image](https://github.com/vicharak-in/vaaman-ahb-verilog/assets/102940423/f81fc492-5495-4a15-9f8c-865e65ba8f89)



> sram_bist_8kx8 module 
   * This is the design for bist test and dft to check the sram functionality.

> mux and decoder module - Bus interconnecting modules
   * The decoder provides a select signal for each subordinate on bus.
   *  Any response data from the selected Subordinate, passes through the read data multiplexor to
the Manager.
![image](https://github.com/vicharak-in/vaaman-ahb-verilog/assets/102940423/f4521227-ccf7-4b29-a8b6-09bd3f0eb318)
![image](https://github.com/vicharak-in/vaaman-ahb-verilog/assets/102940423/85e36d5c-d21a-4929-9534-56b8401667f0)




> top_wrapper_multi_slaves module
   * This module wraps the master and the sram_top module for 3 instances and hence 3 slaves.

