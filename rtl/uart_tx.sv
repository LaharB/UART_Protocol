module uart_tx(
    input tx_clk, tx_start,
    input rst,
    input [7:0] tx_data,
    input [3:0] length, //5, 6, 7, 8 bits 
    input parity_type, parity_en, //1/0 - odd/even parity 
    input stop2, //for 2 stop bits 
    output reg tx, tx_done, tx_err
);

    logic [7:0] tx_reg; //temp reg to store 8-bit tx_data input 

    logic start_b    = 0; //start_bit = 0 -> start of transmission
    logic stop_b     = 1; //stop_bit = 1-> stop of transmission
    logic parity_bit = 0; //to store parity value 
    integer count    = 0; //to keep count of bit position of tx_reg

    typedef enum bit [2:0] {idle = 0, start_bit = 1, send_data = 2, send_parity = 3, send_first_stop = 5, done = 6} state_type;
    state_type state = idle,  next_state = idle;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////// parity checking
    always@(posedge tx_clk) begin
        if(parity_type == 1'b1)begin
            case(length) //odd parity 
                4'd5 : parity_bit = ^(tx_data[4:0]);
                4'd6 : parity_bit = ^(tx_data[5:0]);
                4'd7 : parity_bit = ^(tx_data[6:0]);
                4'd8 : parity_bit = ^(tx_data[7:0]);
                default: parity_bit = 1'b0;
            endcase 
            end
        else begin
            case(length) //even parity
            //bitwise xnor doesnt have dual behavior according to no of input bit
                4'd5 : parity_bit = ~^(tx_data[4:0]));
                4'd6 : parity_bit = ~^(tx_data[5:0]); 
                4'd7 : parity_bit = ~^(tx_data[6:0]));
                4'd8 : parity_bit = ~^(tx_data[7:0]);
                default: parity_bit = 1'b0;  
            endcase
        end 
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////
//////// reset decoder 
    always@(posedge tx_clk) begin
        if(rst)
            state <= idle;
        else 
            state <= next_state; 
    end

//////////////////////////////////////////////////////////////////////////////////////////////////// 
///////// next_state decoder and output decoder
    always@(*) begin
        case(state)
            idle : 
                begin
                    tx_done = 0;
                    tx = 1'b1; //be default, tx line is HIGH
                    tx_reg = {8{1'b0}};
                    tx_err = 0;
                    if(tx_start)
                        next_state = start_bit;
                    else 
                        next_state = idle;
                end 
        /////////////////////////////////////////////////////////////////////////////////////////////
            start_bit : 
                begin
                    tx_reg = tx_data; //passing to temp reg
                    tx = start_b; //making tx line 0 
                    next_state = send_data;
                end
        ///////////////////////////////////////////////////////////////////////////////////////////
            send_data :
                begin
                    if(count < ( length - 1)) //say len = 5 -> 0 1 2 3 and 5th bit in else bit 
                        begin
                            tx = tx_reg[count]; //passing bits 1 by 1 
                            next_state = send_data;    
                        end
                    else if(parity_en)
                        begin
                            tx = tx_reg[count];
                            next_state = send_parity; //if parity bit is there
                        end
                    else
                        begin
                            tx = tx_reg[count];
                            next_state = send_first_stop; //parity bit is not used , send stop bit
                        end
                end
        //////////////////////////////////////////////////////////////////////////////////////////////
            send_parity :
                begin
                    tx = parity_bit; //from parity_gen
                    next_state = send_first_stop;
                end        
        ///////////////////////////////////////////////////////////////////////////////////////////////
            send_first_stop :
                begin
                    tx = stop_b; //making tx line HIGH 
                    if(stop2)
                        next_state = send_sec_stop;
                    else 
                        next_state = done;
                end       
        ////////////////////////////////////////////////////////////////////////////////////////////////
            send_sec_stop :
                begin
                    tx = stop_b; //making tx line HIGH again for 2nd stop bit
                    next_state = done;
                end
        ///////////////////////////////////////////////////////////////////////////////////////////////
            done :
                begin
                    tx_done = 1'b1; //making tx_done HIGH upon completion
                    next_state = idle;
                end   
        //////////////////////////////////////////////////////////////////////////////////////////////
            default : next_state = idle;

        endcase
    end
///////////////////////////////////////////////////////////////////////////////////////////////////////
///// sequential logic ofr count value 
    always@(posedge clk)
        begin
            case(state)
                idle : begin
                    count <= 0;
                end

            endcase
        end 








endmodule 