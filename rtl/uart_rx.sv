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
                            next_state = start_bit;
                        else 
                            next_state = idle;
                    end
            ///////////////////////////////////////////////////////////////////////////////////////

                start_bit :
                    begin
                        if(tick_count == 7 && rx) //check in the middle rx_clk tick, if start_bit is 1 then go back to idle 
                            begin
                                next_state = idle;
                            end
                        else if(tick_count == 15)
                            begin    
                                next_state = recv_data; //if start_bit is 0 then start receiving data 
                            end
                        else 
                            begin
                                next_state = start_bit; //if count != 7 and start_bit is not HIGH then stay in start_bit until middle clk tick 
                            end
                    end
            /////////////////////////////////////////////////////////////////////////////////////////

                recv_data : 
                    begin
                        if(tick_count = 7) //sample at middle tick
                            begin
                                datard[7:0] = {rx, datard[7:1]}; 
                            end
                        else if(tick_count == 15 && bit_count == (length - 1))
                            begin
                                case(length)
                                    5: rx_out = datard[7:3];
                                    6: rx_out = datard[7:2];
                                    
                                endcase
                            end 
                    end


            endcase
        end
    

endmodule