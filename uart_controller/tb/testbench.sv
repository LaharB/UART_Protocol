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
//SEQ WITH PARITY
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
                tr.tx_data = {1'b0, tr.tx_data[7:1]}; //7-bits data so MSBs will be appended with 0s
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
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//SEQ WITHOUT PARITY
// SEQ 7 - fixed length = 5 - variable baud WITHOUT parity
class rand_baud_len5 extends uvm_sequence#(transaction);
`uvm_object_utils(rand_baud_len5)

    transaction tr;

    //std constr 
    function new(input string path = "rand_baud_len5");
        super.new(path);
    endfunction

    //body()
    virtual task body();
        repeat(5)
            begin
                tr = transaction::type_id::create("tr"); //1 arg as uvm_obj
                start_item(tr); //send req to seq and wait for grant 
                assert(tr.randomize);
                tr.oper = length5wop;
                tr.rst = 1'b0;
                tr.length = 5;
                tr.tx_data = {3'b00, tr.tx_data[7:3]}; //5-bits data so MSBs will be appended with 0s
                tr.tx_start = 1'b1;
                tr.rx_start = 1'b1;
                tr.parity_en = 1'b1;
                tr.stop2 = 1'b0;
                finish_item(tr); //send packet to seqr and wait for item done 
            end 
    endtask

endclass
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// SEQ 8 - fixed length = 6 - variable baud WITHOUT parity
class rand_baud_len6 extends uvm_sequence#(transaction);
`uvm_object_utils(rand_baud_len6)

    transaction tr;

    //std constr 
    function new(input string path = "rand_baud_len6");
        super.new(path);
    endfunction

    //body()
    virtual task body();
        repeat(5)
            begin
                tr = transaction::type_id::create("tr"); //1 arg as uvm_obj
                start_item(tr); //send req to seq and wait for grant 
                assert(tr.randomize);
                tr.oper = length6wop;
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
// SEQ 9 - fixed length = 7 - variable baud with parity
class rand_baud_len7 extends uvm_sequence#(transaction);
`uvm_object_utils(rand_baud_len7)

    transaction tr;

    //std constr 
    function new(input string path = "rand_baud_len7");
        super.new(path);
    endfunction

    //body()
    virtual task body();
        repeat(5)
            begin
                tr = transaction::type_id::create("tr"); //1 arg as uvm_obj
                start_item(tr); //send req to seq and wait for grant 
                assert(tr.randomize);
                tr.oper = length7wop;
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
// SEQ 10 - fixed length = 8 - variable baud with parity
class rand_baud_len8 extends uvm_sequence#(transaction);
`uvm_object_utils(rand_baud_len8)

    transaction tr;

    //std constr 
    function new(input string path = "rand_baud_len8");
        super.new(path);
    endfunction

    //body()
    virtual task body();
        repeat(5)
            begin
                tr = transaction::type_id::create("tr"); //1 arg as uvm_obj
                start_item(tr); //send req to seq and wait for grant 
                assert(tr.randomize);
                tr.oper = length8wop;
                tr.rst = 1'b0;
                tr.length = 6;
                tr.tx_data = tr.tx_data[7:0];
                tr.tx_start = 1'b1;
                tr.rx_start = 1'b1;
                tr.parity_en = 1'b1;
                tr.stop2 = 1'b0;
                finish_item(tr); //send packet to seqr and wait for item done 
            end 
    endtask

endclass
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//WE dont have to create any uvm_sequencer class, it gets created automatically
//4.DRIVER - uvm_component 
class driver extends uvm_driver#(transaction);
    `uvm_component_utils(driver)

    transaction tr; //data container to store the packet sent by seq through seqr
    virtual uart_if vif; //instance to get access to interface through tb_top

    //std constr
    function new(input string path = "driver", uvm_component parent = null); //2 args as uvm_component 
        super.new(path, parent);
    endfunction

    //build_phase = function + super as they do not consume time 
    //virtual as skeleton is defined inside PARENT class: uvm_component 
    virtual function build_phase(uvm_phase pahse);
        super.build_pahse(phase);
        tr = transaction::type_id::create("driver"); //1 arg as uvm_obj

        if(!(uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)))
            `uvm_error("DRV", "Unable to access interface");
    endfunction 

    //2 tasks declared outside run_phase to simplify - reset_dut task and drive task
    task reset_dut();
        repeat(5)
            begin
                vif.rst <= 1'b1; //apply rst to DUT manually
                vif.tx_start <= 1'b0; 
                vif.rx_start <= 1'b0;
                vif.tx_data <= 8'b0;
                vif.baud <= 16'h0000;
                vif.length <= 4'h0;
                vif.parity_en <= 1'b0;
                vif.parity_type <= 1'b0;
                vif.stop2 <= 1'b0;
                `uvm_info("DRV", "System Reset : Start of Simulation", UVM_MEDIUM);
                @(posedge vif.clk); //wait of 1 clk tick
            end
    endtask

    task drive(); 
        reset_dut();
        forever //usign forever as driver has to be always ready to get new packets as well as send stimulus to DUT
            begin
                seq_item_port.get_next_item(tr); //convey the seqr that drv is ready to recv next packet from seq
                    vif.rst <= 1'b0; //deassert rst
                    vif.tx_start <= 1'b1; //start tx
                    vif.rx_start <= 1'b1; //start rx
                    vif.baud <= tr.baud;
                    vif.length <= tr.length;
                    vif.parity_en <= tr.parity_en;
                    vif.parity_type <= tr.parity_type;
                    vif.stop2 <= tr.stop2;
                seq_item_port.item_done(tr); //send item_done to seqr and get new packet in non-blocking fashion     
                `uvm_info("DRV", $sformatf("BAUD:%0d LEN:%0d PAR_TY:%0d PAR_EN:%0d STOP: %0d TX_DATA: %0d", tr.baud, tr.length, tr.parity_type, tr.parity_en, tr.stop2, tr.tx_data), UVM_NONE); 
                //wait for 1 clk tick 
                @(posedge vif.clk);
                //wait for tx_done and rx_done edge
                @(posedge vif.tx_done);
                @(negedge vif.rx_done);
            end 
    endtask

    //run phase to apply stimulus to DUT - virtual task as time is consumed
    virtual task run(uvm_phase phase);
        drive();
    endtask

endclass