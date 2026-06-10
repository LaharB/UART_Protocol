module clk_gen(
    input clk, rst,
    input [16:0] baud,
    output reg tx_clk, rx_clk //slower clk
);
    int tx_max = 0, rx_max = 0; // tx_max = fclk/baud
    int tx_count = 0, rx_count =0; // to keep count of the clk ticks of faster clock

//calculating tx_max and rx_max value for different baud rate : tx_max = fclk/baud, rx_max = tx_max/16
    always @(posedge clk) begin
        if (rst) begin
            tx_max <= 0;
            rx_max <= 0;
        end 
        else begin
            case(baud)
                4800 : begin
                            tx_max <= 14'd10416;
                            rx_max <= 11'd651;                    
                       end
                9600 : begin
                            tx_max <= 14'd5208; 
                            rx_max <= 11'd325;                  
                       end
                14400 : begin
                            tx_max <= 14'd3472; 
                            rx_max <= 11'd217;                  
                       end
                19200 : begin
                            tx_max <= 14'd2604;
                            rx_max <= 11'd163;                   
                       end
                38400 : begin
                            tx_max <= 14'd1302;
                            rx_max <= 11'd81;                   
                       end
                57600 : begin
                            tx_max <= 14'd868;
                            rx_max <= 11'd54;                   
                       end
                115200: begin 
						  tx_max <=14'd434;	
				          rx_max <=11'd27;
						end
                128000: begin 
						  tx_max <=14'd392;	
				          rx_max <=11'd24;
				    	end
                default: begin
                            tx_max <= 14'd5208; 
                            rx_max <= 11'd325;  
                         end
            endcase
        end    
    end

//generating tx_clk
/*
- here we invert tx_clk when tx_count = tx_max not tx_max/2
- suppose baud is 9600, then tx_max = 5208 then tx_count goes from 0 to 5201 
- at the clk tick 1, tx_count is at 0 so if block runs and tx_count inc to 1 
- so in 5208 clk ticks, tx_count is at 5207 so if block runs and tx_count inc to 5208
- at the 5209th clk tick, count value is 5208 so else block runs
- tx_clk goes from 0 to 1 , similarly after another 5209 clk ticks, tx_clk goes from 1 to 0 
- thus we one complete cycle of tx_clk in 5208 + 1 + 5208 + 1 = 10418 clk ticks of faster clk 
*/
    always@(posedge clk) begin
        if(rst) begin
                    tx_max   <= 0;
                    tx_count <= 0;
                    tx_clk   <= 0;
        end
        else begin
            if(tx_count < tx_max/2)  
                begin 
                tx_count <= tx_count + 1;    
                end
            else begin              
                tx_count <= 0;
                tx_clk <= ~tx_clk; 
            end
        end
    end
////////////////////////////////////////////////////////////////////////////
//generating rx_clk
    always@(posedge clk)
        begin
            if(rst) begin
                rx_max   <= 0;
                rx_count <= 0;
                rx_clk   <= 0;
            end
            else begin
                if(rx_count < rx_max) begin
                    rx_count <= rx_count + 1;
                end
                else begin
                    rx_count <= 0;
                    rx_clk <= ~rx_clk;
                end
            end
        end

endmodule