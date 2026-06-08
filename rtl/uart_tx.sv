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

    //////////parity checking
    always@(posedge tx_clk) begin
        if(parity_type == 1'b1) begin
            begin
                case(length)
                    4'd5 : parity_bit = ~(tx_data[4:0]);
                    4'd6 : parity_bit = ~(tx_data[5:0]);
                    4'd7 : parity_bit = ~(tx_data[6:0]);
                    4'd8 : parity_bit = ~(tx_data[7:0]);
                    default: parity_bit = 1'b0;
                endcase 
            end
        else begin
            case(length)
                4'd5 : 
            endcase
        end 
        end
    end



endmodule 