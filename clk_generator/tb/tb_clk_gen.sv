`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

//enum for operation mode
typedef enum bit [1:0] {reset_asserted = 0, random_baud = 1} oper_mode;

//////////////////////////////////////////////////////////////////////////////////////////
//1.transaction class - dynamic component - UVM_OBJECT is PARENT
class transaction extends uvm_sequence_item; 
//register the class to factory for field macros
    `uvm_object_utils(transaction) 

    //add the interface signals - inputs for randomization and outputs 
    // logic clk, rst; clk will be generated from tb and rst will be manually asserted 
    rand logic [16:0] baud;
    logic tx_clk; 

    oper_mode oper; //custom datatype variable for operation mode
    real period; //to calculate the time period and thus the count value 

    constraint baud_c { baud inside {4800, 9600, 14400, 19200, 38400, 57600}; };

    //standard constructor for uvm_object - 1 arg as dynamic component
    function new(input string path = "null");
        super.new(path);
    endfunction
    
endclass

////////////////////////////////////////////////////////////////////////////////////////////
//2.Creating various sequences by extending uvm_sequence - dynamic component
//2.1 Reset clk SEQ
class reset_clk extends uvm_sequence#(transaction);
    `uvm_object_utils(reset_clk)

    transaction tr; //data container instance to send the randomized data to driver

    //constructor for uvm_sequence
    function new(input string path = "null");
        super.new(path);
    endfunction

    virtual task body(); //virtual as body skeleton is defined in uvm_object(PARENT)
        repeat(5) //create 5 transactions
            begin
                //create the object for tr instance 
                tr = transaction::type_id::create("tr"); //1 arg as uvm_object type, use instance name as path name 
                start_item(tr); //send req to sequencer and wait_for_grant 
                assert(tr.randomize);
                tr.oper = reset_asserted; //manually declaring value of oper
                finish_item(tr); //send packet to sequencer and wait for item_done from driver      
            end
    endtask

endclass

/////////////////////////////////////////////////////////////////////////////////////////
//2.2 Variable baud SEQ
class variable_baud extends uvm_sequence#(transaction);
    `uvm_object_utils(variable_baud)

    transaction tr; //data container instance to send the randomized data to driver

    //constructor for uvm_sequence
    function new(input string path = "variable_baud");
        super.new(path);
    endfunction

    virtual task body(); //virtual as body skeleton is defined in uvm_object(PARENT)
        repeat(5) //create 5 transactions
            begin
                //create the object for tr instance 
                tr = transaction::type_id::create("tr"); //1 arg as uvm_object type, use instance name as path name 
                start_item(tr); //send req to sequencer and wait_for_grant 
                assert(tr.randomize);
                tr.oper = random_baud; //manually declaring value of oper
                finish_item(tr); //send packet to sequencer and wait for item_done from driver      
            end
    endtask

endclass

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//We dont need to create any uvm_sequencer class in UVM, its automatically created
//3.DRIVER - static component(remains till the end of sim) - UVM_COMPONENT is PARENT - 2 args
class driver extends uvm_driver#(transaction);
    `uvm_component_utils(driver)

    transaction tr; //data container to receive packet sent by seq through seqr
    virtual clk_if vif; //for getting access to interface 

    //constructor for uvm_driver
    function new(input string path = "driver", uvm_component parent = null);//2 args
        super.new(path, parent);
    endfunction 

    //function for build_phase - use function + super as build_phase does not consume time
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = transaction::type_id::create("tr"); //1 arg as uvm_object type
        //getting access to interface through tb
        if(!uvm_config_db#(virtual clk_if)::get(this , "", "vif", vif)) //this gives whole path - uvm_test_top.env.agent.drv.aif
            `uvm_error("DRV", "Unable to acess Interface");
    endfunction

    //run_phase to drive stimulus to DUT
    //use task for run_phase as it consumes and no super method required
    virtual task run_phase(uvm_phase phase);
        forever 
            begin
               seq_item_port.get_next_item(tr); //communicate that drv is ready to get next packet(s) 
                    if(tr.oper == reset_asserted)
                        begin
                            vif.rst <= 1'b1; //asserting rst manually in the DUT 
                            @(posedge vif.clk); //wait for 1 clk tick
                        end
                    else if(tr.oper == random_baud)
                        begin
                            `uvm_info("DRV", $sformatf("Baud: %0d", tr.baud), UVM_NONE);
                            vif.rst  <= 1'b0; //manually deasserting rst in the DUT
                            vif.baud <= tr.baud; //passing the random baud to DUT 
                            //wait for 1 clk tick and 2 tx_clk ticks so that DUT gets enough to process the stimuli 
                            @(posedge vif.clk);
                            repeat(2) @(posedge vif.tx_clk);        
                        end
               seq_item_port.item_done(); //inform the seqr that packet has been applied to DUT and send next packet 
            end
    endtask
endclass

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//4.MONITOR - static component(remains till the end of sim) - UVM_COMPONENT is PARENT - 2 args
class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    transaction tr; //data container to store response of DUT and send it to SCO
    virtual clk_if vif; //for getting access to interface 
    uvm_analysis_port#(transaction) send; //analysis port to connect to SCO
    //to store the simulation time between 2 tx_clk ticks 
    real ton = 0;
    real toff = 0; 

    //constructor for uvm_monitor
    function new(input string path = "monitor", uvm_component parent = null);//2 args
        super.new(path, parent);
    endfunction 

    //function + super for build_phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        send = new("send", this); //constructor for send port inside build_phase
        tr = transaction::type_id::create("tr"); //1 arg as uvm_object type
        //getting access to interface through tb
        if(!uvm_config_db#(virtual clk_if)::get(this, "", "vif", vif)) //uvm_test_top.env.agent.drv.aif
            `uvm_error("MON", "Unable to acess Interface");
    endfunction

    //run_phase to get the response of DUT 
    virtual task run_phase(uvm_phase phase);
        forever 
            begin
                @(posedge vif.clk); //wait for 1 clk tick as in driver 
                if(vif.rst)
                    begin
                        tr.oper = reset_asserted;
                        ton     =  0;
                        toff    = 0;
                        `uvm_info("MON", "SYSTEM RESET DETECTED", UVM_NONE);
                        send.write(tr); //calling write task in SCO
                    end
                else 
                    begin
                        tr.baud = vif.baud;
                        tr.oper = random_baud;
                        ton = 0;
                        toff = 0;
                        @(posedge vif.tx_clk);
                        ton  = $realtime; //sample time at tx_clk
                        @(posedge vif.tx_clk);
                        toff = $realtime; //sample time at next tx_clk
                        tr.period = toff - ton;
                        `uvm_info("MON", $sformatf("Baud: %0d, Period: %0f", tr.baud, tr.period), UVM_NONE);
                        send.write(tr); //calling write task in SCO
                    end
            end
    endtask

endclass

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//5.SCOREBOARD - static component(remains till the end of sim) - UVM_COMPONENT is PARENT - 2 args 
class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    real count = 0; //to calculate the count value by using period
    real baudcount; 

    //2 args - datatype and the class name where write method is added
    uvm_analysis_imp#(transaction, scoreboard) recv; //analysis implementation to connect to mon
    
    //constrcutor for uvm_component
    function new(input string path = "sco", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    //function + super build_phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        recv = new("recv", this); //constr for recv imp inside build_phase
    endfunction

    //write method 
    virtual function void write(transaction tr);
        count = tr.period/20; //Tbaud(Period)/Tclk where fclk = 50Mhz
        baudcount = count; //just passing
        `uvm_info("SCO", $sformatf("Baud: %0d, count: %0f", tr.baud, count), UVM_NONE);

        //comparison 
        case(tr.baud)
            4800: begin
                if(baudcount == 10418) //10416 + 2
                    `uvm_info("SCO", "TEST PASSED", UVM_NONE)
                else
                    `uvm_info("SCO", "TEST FAILED", UVM_NONE)
            end

            9600: begin
                if(baudcount == 5210) //5208 + 2
                    `uvm_info("SCO", "TEST PASSED", UVM_NONE)
                else
                    `uvm_info("SCO", "TEST FAILED", UVM_NONE)
            end

            14400: begin
                if(baudcount == 3474) //3472 + 2
                    `uvm_info("SCO", "TEST PASSED", UVM_NONE)
                else
                    `uvm_info("SCO", "TEST FAILED", UVM_NONE)
            end

            19200: begin
                if(baudcount == 2606) //2604 + 2
                    `uvm_info("SCO", "TEST PASSED", UVM_NONE)
                else
                    `uvm_info("SCO", "TEST FAILED", UVM_NONE)
            end

            38400: begin
                if(baudcount == 1304) //1302 + 2
                    `uvm_info("SCO", "TEST PASSED", UVM_NONE)
                else
                    `uvm_info("SCO", "TEST FAILED", UVM_NONE)
            end

            57600: begin
                if(baudcount == 870) //868 + 2
                    `uvm_info("SCO", "TEST PASSED", UVM_NONE)
                else
                    `uvm_info("SCO", "TEST FAILED", UVM_NONE)
            end
        endcase
    endfunction

endclass

////////////////////////////////////////////////////////////////////////////////////////
//6.AGENT - uvm_component 
//connect drv and seq 
class agent extends uvm_agent;
    `uvm_component_utils(agent)

    //inside agent, we have seqr, drv and mon
    uvm_sequencer#(transaction) seqr;
    driver d;
    monitor m;

    //std constr for uvm_comp
    function new(input string path = "agent", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    //func + super for build_phase 
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //object creation for seqr, d and m instances
        seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this); //2 args as uvm_comp type
        d = driver::type_id::create("d", this); //2 arg as uvm_comp type
        m = monitor::type_id::create("m", this); //2 args as uvm_comp type
    endfunction

    //funct + super for connect phase to connect seqr and drv
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        d.seq_item_port.connect(seqr.seq_item_export); //connecting drv and seqr
    endfunction

endclass

///////////////////////////////////////////////////////////////////////////////////////////////////
//8.ENVIRONMENT - uvm_comp 
//inisde env, we have agent and we connect mon and sco
class env extends uvm_env;
    `uvm_component_utils(env)

    //instances
    agent a;
    scoreboard sco;

    //constr for env
    function new(input string path = "env", uvm_component parent = null);
        super.new(path, parent); //2 args
    endfunction

    //build_phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //object creation
        a   = agent::type_id::create("a", this); //2 args as uvm_comp type
        sco = scoreboard::type_id::create("sco", this); //2 args uvm_comp type
    endfunction

    //connect phase to connect mon and sco
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a.m.send.connect(sco.recv);
    endfunction

endclass

/////////////////////////////////////////////////////////////////////////////////////////
///9.TEST - we start the seqr from TEST using various sequences
class test extends uvm_test;
    `uvm_component_utils(test)

    //instances of env and various sequences
    env e;
    variable_baud vbar;
    reset_clk rclk;

    //std constr for uvm_comp
    function new(input string path = "test", uvm_component parent = null);
        super.new(path, parent); //2 args
    endfunction

    //build_phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //object creation
        e    = env::type_id::create("e", this); //2 args as uvm_comp type
        vbar = variable_baud::type_id::create("vbar"); //1 arg only as uvm_object
        rclk = reset_clk::type_id::create("rclk"); //1 arg only as uvm_object
    endfunction

    //run_phase to start the seqr
    virtual task run_phase(uvm_phase phase);
        //to hold the simulator till all the sequences are over 
        phase.raise_objection(this);
        //start calls the body() inside resp SEQ and starts the seqr
            vbar.start(e.a.seqr); 
            #20;
            //rclk.start(e.a.seqr);
            //#20
        phase.drop_objection(this);
    endtask

endclass

/////////////////////////////////////////////////////////////////////////////////////////////
//11.TESTBENCH - we give access of inteface to drv and mon
//               generate clk
//               run test class from tb - uvm_component 
module tb();

    clk_if vif(); //in tb, parenthesis are reqd for interface instance

    //connectiong interface signals to DUT
    clk_gen DUT(
        .clk(vif.clk),
        .rst(vif.rst),
        .baud(vif.baud),
        .tx_clk(vif.tx_clk)
    );

    //initialize clk 
    initial begin
        vif.clk = 1'b0;    
    end

    //clk generation
    always #10 vif.clk = ~vif.clk; //50 MHz, 20ns Period 

    //run the test
    initial begin
        //giving the access of interface 
        uvm_config_db#(virtual clk_if)::set(null, "*", "vif", vif); //null gives the path - uvm_test_top.* i.e env.agent.drv and env.agent.mon 
        //run test
        run_test("test");
    end

endmodule