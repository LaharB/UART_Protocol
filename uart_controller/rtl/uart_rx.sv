module uart_rx(
    input rx_clk, rx_start,
    input rst, 
    input rx, //input line 
    input [3:0] length,
    input parity_type, parity_en,
    input stop2,
    output reg [7:0] rx_out,
    output logic rx_done, rx_error
);
    logic parity = 0; //to calc parity from data received
    logic [7:0] datard = 0; //to store data from tx bit by bit 
    int tick_count = 0; //to count the clk tick 
    int bit_count = 0; //to count bit no in datard
    
    typedef enum bit [2:0] {idle = 0, start_bit = 1, recv_data = 2, check_parity = 3, check_first_stop = 4, check_sec_stop = 5, done = 6} state_type;
    state_type state = idle, next_state = idle;

//////////  reset decoder
    always@(posedge rx_clk)
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
                        if(tick_count == 7) //sample at middle tick
                            begin
                                datard[7:0] = {rx, datard[7:1]}; 
                            end
                        else if(tick_count == 15 && bit_count == (length - 1))
                            begin
                                case(length)
                                    5: rx_out = datard[7:3];
                                    6: rx_out = datard[7:2];
                                    7: rx_out = datard[7:1];
                                    8: rx_out = datard[7:0];
                                endcase
                            ////////////////////////////////////////////////////
                            //parity_generator from datard received 
                                if(parity_type)
                                    parity = ^datard;
                                else 
                                    parity = ~^datard;
                            end

                        else 
                            next_state = recv_data; //if tick_count != 7 or 15 & bit_length != 15, stay here 
                    end
            ////////////////////////////////////////////////////////////////////////////////////////////////

                check_parity : 
                    begin
                        if(tick_count == 7)
                            begin
                                if(rx == parity) //compare bit received 
                                    rx_error = 1'b0; 
                                else    
                                    rx_error = 1'b1;
                            end 
                        else if (tick_count == 15)
                            begin
                                next_state = check_first_stop;
                            end
                        else 
                            begin
                                next_state = check_parity;
                            end                       
                    end
            ///////////////////////////////////////////////////////////////////////////////////////////////

                check_first_stop : 
                        begin
                            if(tick_count == 7)
                                begin
                                    if(rx != 1'b1) //if stop_bit != 1 then error 
                                        rx_error = 1'b1;
                                    else 
                                        rx_error = 1'b0;
                                end    
                            else if(tick_count == 15)
                                begin
                                    if(stop2)
                                        next_state = check_sec_stop;
                                    else 
                                        next_state = done; 
                                end
                        end
            ////////////////////////////////////////////////////////////////////////////////////////////////

                check_sec_stop :
                    begin
                        if(tick_count == 7)
                            begin
                                if(rx != 1'b1) //if 2nd stop_bit != 1 then error 
                                    rx_error = 1'b1;
                                else 
                                    rx_error = 1'b0;
                            end    
                        else if(tick_count == 15)
                            begin
                                next_state = done; 
                            end
                        
                        end
            ////////////////////////////////////////////////////////////////////////////////////////////

                done :
                    begin
                        rx_done = 1'b1;
                        next_state = idle;
                        rx_error = 1'b0;
                    end
            /////////////////////////////////////////////////////////////////////////////////////////////
                default : next_state = idle;
            
            endcase
        end
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ////// tick_count and bit_count 
    always@(posedge rx_clk)
        begin
            case(state)
                idle :
                    begin
                        tick_count <= 0;
                        bit_count  <= 0;
                    end
        ////////////////////////////////////////////////////////////////////////
                start_bit :
                    begin
                        if(tick_count < 15)
                            tick_count <= tick_count + 1;
                        else 
                            tick_count <= 0;
                    end
        ///////////////////////////////////////////////////////////////////////////
                recv_data :
                    begin
                        if(tick_count < 15)    
                            tick_count <= tick_count + 1;
                        else 
                            tick_count <= 0; 
                            //bit_count will incr only in recv_data state  
                            bit_count <= bit_count + 1; //if count > 15 then go to next bit_position     
                    end
        ////////////////////////////////////////////////////////////////////////////
                check_parity :
                    if(tick_count < 15)
                        tick_count <= tick_count + 1;
                    else
                        tick_count <= 0;
        ////////////////////////////////////////////////////////////////////////////
                check_first_stop :
                    begin
                        if(tick_count < 15)
                            tick_count <= tick_count + 1;
                        else 
                            tick_count <= 0;    
                    end
        ////////////////////////////////////////////////////////////////////////////
                check_sec_stop :
                    begin
                        if(tick_count < 15)
                            tick_count <= tick_count + 1;
                        else 
                            tick_count <= 0;    
                    end
        ////////////////////////////////////////////////////////////////////////////
                done :
                    begin
                        tick_count <= 0; 
                        bit_count  <= 0;     
                    end
            endcase    
        end
endmodule