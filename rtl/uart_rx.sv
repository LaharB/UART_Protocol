module uart_rx (
    input rx_clk, rx_start,
    input rst, 
    input rx, //input line 
    input [3:0] length,
    input parity_type, parity_en,
    input stop2,
    output reg [7:0] rx_out,
    ouptut logic rx_done, rx_error
);
    logic parity = 0;
    logic [7:0] datard = 0; //to store data from tx bit by bit 
    int tick_count = 0; //to count the clk tick 
    int bit_count = 0; //to count bit no in datard
    
    typedef enum bit [2:0] {idle = 0, start_bit = 1, recv_data = 2, check_parity = 3, check_first_stop = 4, check_sec_stop = 5, done = 6} state_type;
    state_type state = idle, next_state = idle;

//////////  reset decoder
    always@(posedge clk)
        begin
            if(rst)
                state <= idle;
            else
                state <= next_state; 
        end

//////////////////////////////////////////////////////////////////////////////////////////
///////   next_state decoder + output decoder    
    always@(*)
        begin
            case(state)
                idle : 
                    begin
                        rx_done = 0;
                        rx_error = 0;
                        if(rx_start && !rx) //if start_bit is 0 then only start receiving
                            
                    end


            endcase
        end
    

endmodule