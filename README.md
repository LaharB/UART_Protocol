This project showcases the design and verification of - 

- an UART Clk Generator that can produce variable transmitter clk and receiver clk signals according to variable baud rate.
- an UART Controller which will be consisting of an UART transmitter, UART receiver and the clk generator.

The verification of the UART Controller has been performed by an UVM-based testbench architecture using Siemens Questa Sim 10.7 Simulator.

--------------------------------------------------------------------------

# Technical Specifications & Features

The UART Controller has the following features:

- Supported Baud Rates: 4800, 9600, 14400, 19200, 38400, 57600
- Configurable data widths from 5 to 8 bits
- Parity support: Even and Odd
- Stop bit configurations: 1 and 2 bits supported

--------------------------------------------------------------------

# Protocol Overview and Charateristics

- UART stands for Universal Asynchronous Receiver and Transmitter. It is a hardware communication protocol that allows two digital devices (such as microcontrollers, sensors, or computers) to exchange data serially, bit-by-bit. 
- Full-Duplex: It can transmit and receive data simultaneously using two dedicated data lines.
- Communication occurs over just two wires: one for transmitting (TX) and one for receiving (RX). It is considered **asynchronous** because the transmitter and receiver do not share a common clock signal.
- They rely on a pre-agreed transmission speed (Baud Rate) to decode the data.
  
--------------------------------------------------------------------

# UART Connections 

A basic full-duplex UART connection is simple: each device’s TX pin connects to the other device’s RX pin.

![alt text](uart_controller/docs/UART_connection.png)
  
--------------------------------------------------------------------

# Data Framing Structure

- Data framing defines how a single data byte is structured for transmission. This ensures that the receiving device can correctly identify where a data packet begins and ends.

- UART Frame Format:
**Idle high -> Start low -> Data bits LSB first -> Optional parity -> Stop high**

![alt text](uart_controller/docs/UART_Data_Frame.png)

- Each field occupies one bit time unless a configuration uses multiple stop bits or a different data width.

- When the line is idle (no data is being sent), it is held at a logic-high state. The framing process converts parallel data from the CPU into a serial frame, which typically consists of:

| Bit type | Description |
| :--- | :--- |
| **Start Bit** | The transmission begins with a transition from high to low (logic 0), signaling the start of the data frame. |
| **Data Bits** | This is the actual payload, commonly 8 bits long (though it can range from 5 to 9 bits). These bits are transmitted Least Significant Bit (LSB) first. |
| **Parity Bit (Optional)** | A bit used for error detection. It can be configured as "even" or "odd" to ensure the total number of '1's in the frame matches the selected parity, or it can be set to "none". |
| **Stop Bit(s)** | The frame ends with 1 or 2 bits held at logic-high (1), signaling the end of the byte and giving the receiver time to prepare for the next frame. |

- Once received, the receiving UART strips away these **framing bits** and converts the data back into a parallel format for the internal data bus.

--------------------------------------------------------------------

# Baud Rate, Oversampling and Throughput

- As there is no shared clock line, both communicating devices must agree to operate at the exact same **Baud Rate, which is the number of *bits* transmitted per second.**
- This is not the same as **Throughput** which is the amount of data processed **(useful data)** or operations completed by a digital circuit per unit of time.
- For example, at a 9600 baud rate, each individual bit duration is precisely 104.16 µs (1/9600).
- In a standard 8-N-1 configuration (1 Start, 8 Data, No Parity, 1 Stop), transmitting a single byte requires 10 bit periods. Therefore, at 9600 baud, the **maximum data throughput** or **byte rate** is roughly 960 bytes per second.

## Receiver Oversampling: 

To read this incoming data accurately, the receiver uses a technique called oversampling. The receiver's clock is generated to run much faster than the incoming data—typically 16 times the baud rate. This allows the receiver to sample the incoming signal multiple times per bit duration, effectively pinpointing the precise middle of each bit pulse to avoid reading errors during edge transitions.

--------------------------------------------------------------------

# Hardware Architecture and FSM Design

The RTL design of the UART is typically divided into **three primary modules:**

## Clock Generator 

This module takes the target baud rate (Baud[16:0]), the system clock (Fclk), and the reset signal (rst) to output two distinct clocks: tx_clk for the transmitter, and rx_clk (the 16x oversampled clock) for the receiver.

## Transmitter (Uart_tx)

- The transmitter is responsible for parallel-to-serial conversion
- It is governed by a 7-state Finite State Machine (FSM):

    idle $\rightarrow$ start_bit (drives low) $\rightarrow$ send_data $\rightarrow$ send_parity $\rightarrow$ send_first_stop (drives high) $\rightarrow$ send_sec_stop $\rightarrow$ done

## Receiver (Uart_rx)

- The receiver is responsible for serial-to-parallel conversion using the 16x oversampled clock.
- It is also governed by a 7-state FSM that utilizes the oversampled clock to recover the data:
  
  idle $\rightarrow$ start_bit (validates the low transition) $\rightarrow$ recv_data $\rightarrow$ check_parity $\rightarrow$ check_first_stop $\rightarrow$ check_sec_stop $\rightarrow$ done

--------------------------------------------------------------------------

# Standard Error Conditions

A high-quality UART IP must detect and flag protocol violations.

- **Framing Error:** The expected logic-high Stop Bit was not detected at the end of the frame. This typically indicates a baud rate mismatch or severe line noise.
- **Parity Error** : The calculated parity of the received payload does not match the received parity bit, indicating data corruption during transit.
- **Overrun Error:** The receiver's internal buffer (or FIFO) is full, and a new serial byte arrives before the host processor has read the previous data, causing data loss.
- **Break Condition:** The RX line is held at logic-low for a duration longer than an entire frame transmission.

**NOTE: Here I have implemeted only 2 error checks, namely Framing Error and Parity Error.**

--------------------------------------------------------------------------

<details><summary>Schematic</summary><br>

The Schematics has been generated using Questasim 10.7c.

## Clock Generator 

![alt text](clk_generator/docs/Schematic_clk_generator.png)

## UART Top Module 

![alt text](uart_controller/docs/Schematic_UART_Controller.png)

</details>

--------------------------------------------------------------------------

<details><summary>Simulation</summary><br>

## Clock Generator Simulation Waveform 

![alt text](clk_generator/docs/simulation_waveform_clk_gen.png)

## UART Top module Simulation Waveform

![alt text](uart_controller/docs/Simulation_waveform.png)

</details>

------------------------------------------------------------------------

<details><summary>Console Ouput</summary><br>

## Clock Generator 

![alt text](clk_generator/docs/console_output_P1.png)
![alt text](clk_generator/docs/console_output_P2.png)

## UART Top module

![alt text](uart_controller/docs/Console_output_P1.png)
![alt text](uart_controller/docs/Console_output_P2.png)

</details>

------------------------------------------------------------------------

## Simulation Steps

To compile the RTL and simulate the design , run the run.do file in Questasim.

------------------------------------------

## References & Acknowledgments

- [VLSI Verify Blog on UART Protocol](https://vlsiverify.com/)