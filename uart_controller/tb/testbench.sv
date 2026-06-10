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
// clk will be generated from tb_top
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
// SEQ 1 - random baud with fixed length = 8 and parity enable , parity type random, 1 stop 
class rand_baud extends uvm_sequence#(transaction);
    `uvm_object_utils(rand_baud)

    transaction tr;

    function new(input string path = "rand_baud"); //1 arg as uvm_object
        super.new(path);
    endfunction 

    //body() task to be called by sequence by using start method
    //virtual as skeleton is defined inside PARENT class: uvm_object
    virtual task body(); //body method will be called by sequence
        repeat(5)
            begin
                tr = transaction::type_id::create("tr"); //1 arg only
                start_item(tr); //send req to seqr and wait_for_grant
                assert(tr.randomize);
                tr.op = rand_baud_1_stop; //manually setting oper mode
                tr.length = 8;
                tr.rst = 1'b0;  //deasserting rst manually
                tr.tx_start = 1'b1;
                tr.rx_start = 1'b1;
                tr.parity_en = 1'b1;
                tr.stop2 = 1'b0;
                finish_item(tr); //send packet to seqr and wait for item_done from driver
            end
    endtask

endclass
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SEQ 2 - random baud with fixed length = 8, parity enable, parity type random - 2 stop  
class rand_baud_with_stop extends uvm_sequence#(transaction);
    `uvm_object_utils(rand_baud_with_stop)

    transaction tr; 

    //std constr
    function new(input string path = "rand_baud_with_stop");
        super.new(path);
    endfunction

    //body task - virtual because skeleton is defined inside PARENT class: uvm_object 
    virtual task body();
        repeat(5)
            begin
                tr = transaction::type_id::create("tr"); //1 arg 
                start_item(tr); //send req to seqr and wait_for_grant
                assert(tr.randomize);
                tr.oper = rand_baud_2_stop;
                tr.rst = 1'b0; //deasserting rst manually
                tr.length = 8;
                tr.tx_start = 1'b1;
                tr.rx_start = 1'b1;
                tr.parity_en = 1'b1;
                tr.stop2 = 1'b1; //enabling for 2 stop bits
                finish_item(tr); //send packet to seqr and wait for item_done from drv
            end
    endtask

endclass
/////////////////////////////////////////////////////////////////////////////////////////////////
//SEQ 3 - fixed length = 5 - variable baud - with parity 
class rand_baud_len5p extends uvm_sequence#(transaction);
    `uvm_object_utils(rand_baud_len5p)

    transaction tr;

    //std constr 
    function new(input string path = "rand_baud_len5p");
        super.new(path);
    endfunction

    //body()
    virtual task body();
        repeat(5)
            begin
                tr = transaction::type_id::create("tr"); //1 arg as uvm_obj
                start_item(tr); //send req to seq and wait for grant 
                assert(tr.randomize);
                tr.oper = length5wp;
                tr.rst = 1'b0;
                tr.length = 5;
                tr.tx_data = {3'b000, tr.tx_data[7:3]}; //5-bits data so MSBs will be appended with 0s
                tr.tx_start = 1'b1;
                tr.rx_start = 1'b1;
                tr.parity_en = 1'b1;
                tr.stop2 = 1'b0;
                finish_item(tr); //send packet to seqr and wait for item done 
            end 
    endtask

endclass
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// SEQ 4 - fixed length = 6 - variable baud with parity
class rand_baud_len6p extends uvm_sequence#(transaction);
`uvm_object_utils(rand_baud_len6p)

    transaction tr;

    //std constr 
    function new(input string path = "rand_baud_len6p");
        super.new(path);
    endfunction

    //body()
    virtual task body();
        repeat(5)
            begin
                tr = transaction::type_id::create("tr"); //1 arg as uvm_obj
                start_item(tr); //send req to seq and wait for grant 
                assert(tr.randomize);
                tr.oper = length6wp;
                tr.rst = 1'b0;
                tr.length = 6;
                tr.tx_data = {2'b00, tr.tx_data[7:2]}; //6-bits data so MSBs will be appended with 0s
                tr.tx_start = 1'b1;
                tr.rx_start = 1'b1;
                tr.parity_en = 1'b1;
                tr.stop2 = 1'b0;
                finish_item(tr); //send packet to seqr and wait for item done 
            end 
    endtask

endclass
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// SEQ 5 - fixed length = 7 - variable baud with parity
class rand_baud_len7p extends uvm_sequence#(transaction);
`uvm_object_utils(rand_baud_len7p)

    transaction tr;

    //std constr 
    function new(input string path = "rand_baud_len7p");
        super.new(path);
    endfunction

    //body()
    virtual task body();
        repeat(5)
            begin
                tr = transaction::type_id::create("tr"); //1 arg as uvm_obj
                start_item(tr); //send req to seq and wait for grant 
                assert(tr.randomize);
                tr.oper = length7wp;
                tr.rst = 1'b0;
                tr.length = 7;
                tr.tx_data = {1'b0, tr.tx_data[7:1]}; //6-bits data so MSBs will be appended with 0s
                tr.tx_start = 1'b1;
                tr.rx_start = 1'b1;
                tr.parity_en = 1'b1;
                tr.stop2 = 1'b0;
                finish_item(tr); //send packet to seqr and wait for item done 
            end 
    endtask

endclass
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// SEQ 6 - fixed length = 8 - variable baud with parity
class rand_baud_len8p extends uvm_sequence#(transaction);
`uvm_object_utils(rand_baud_len8p)

    transaction tr;

    //std constr 
    function new(input string path = "rand_baud_len8p");
        super.new(path);
    endfunction

    //body()
    virtual task body();
        repeat(5)
            begin
                tr = transaction::type_id::create("tr"); //1 arg as uvm_obj
                start_item(tr); //send req to seq and wait for grant 
                assert(tr.randomize);
                tr.oper = length8wp;
                tr.rst = 1'b0;
                tr.length = 8;
                tr.tx_data = tr.tx_data[7:0];
                tr.tx_start = 1'b1;
                tr.rx_start = 1'b1;
                tr.parity_en = 1'b1;
                tr.stop2 = 1'b0;
                finish_item(tr); //send packet to seqr and wait for item done 
            end 
    endtask

endclass


