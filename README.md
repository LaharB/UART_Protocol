This project showcases the design and verification of - 

- an UART Clk Generator that can produce variable transmitter clk and receiver clk signals according to variable baud rate.
- an UART Controller which will be consisting of an UART transmitter, UART receiver and the clk generator.

The verification of the UART Controller has been performed by an UVM-based testbench architecture using Siemens Questa Sim 10.7 Simulator.

# Protocol Overview and Charateristics

- UART stands for Universal Asynchronous Receiver and Transmitter. It is a hardware communication protocol that allows two digital devices (such as microcontrollers, sensors, or computers) to exchange data serially, bit-by-bit. 
- Communication occurs over just two wires: one for transmitting (TX) and one for receiving (RX). It is considered **asynchronous** because the transmitter and receiver do not share a common clock signal.
- They rely on a pre-agreed transmission speed (Baud Rate) to decode the data.
  
-------

# Data Framing Structure 



