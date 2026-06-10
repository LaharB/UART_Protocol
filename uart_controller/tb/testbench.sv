`timescale 1ns/1ps 
`include "uvm_macros.svh"
import uvm_pkg::*;

//1.Configuration of ENV
class uart_config extends uvm_object; 
    `uvm_object_utils(uart_config)

    //std constructor for uvm_object
    function new(input string path = "uart_config"); //1 arg as uvm_obj
        super.new(path);
    endfunction

    uvm_active_passive_enum is_active = UVM_ACTIVE;

endclass

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
typedef enum bit [3:0] {
    raud_baud_1_stop = 0, 
    rand_length_1_stop = 1, 
    length5wp = 2, 
    length6wp = 3, 
    length7wp = 4, 
    length8wp = 5, 
    length5wop = 6, 
    length6wop = 7, 
    length7wop = 8, 
    length8wop = 9, 
    raud_baud_2_stop = 11, 
    rand_length_2_stop = 12} oper_mode;

//2.TRANSACTION
class transaction extends uvm_sequence_item; 
    `uvm_object_utils(transaction)

    rand oper_mode op;
// clk will be generated from tb_top and rst will given through driver
         logic tx_start, rx_start;
         logic rst;
    rand logic [7:0] tx_data;
    rand logic [16:0] baud;
    rand logic [3:0] length;
    rand logic parity_type, parity_en;
         logic stop2;
         logic tx_done, rx_done;
         logic tx_err, rx_err;
         logic [7:0] rx_out;
    
    constraint baud_c { baud inside {4800, 9600, 14400, 19200, 38400, 57600}; }
    constraint length_c { length inside {5, 6, 7, 8}; } 

    //std constr 
    function new(input string path = "transaction"); //1 arg
        super.new(path);
    endfunction

endclass
////////////////////////////////////////////////////////////////////////
//Creating SEQUENCES for random length with and without parity 
//3.SEQUENCES
//1 SEQ - random baud with fixed length = 8 with parity
class rand_baud extends uvm_sequence#(transaction);
    `uvm_object_utils 


endclass
