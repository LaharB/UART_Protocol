`timescale 1ns/1ps 
`include "uvm_macros.svh"
import uvm_pkg::*;

//1.configuration of env
class uart_config extends uvm_object; 
    `uvm_object_utils(uart_config)

    function new(input string path = "uart_config"); //1 arg as uvm_obj
        super.new(path);
    endfunction

    uvm_active_passive_enum is_active = UVM_ACTIVE;

endclass

typedef enum bit [3:0] {raud_baud_1_stop = 0, rand_length_1_stop = 1, length5wp = 2, }