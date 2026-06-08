module clk_gen(
    input clk, rst,
    input [16:0] baud,
    output reg tx_clk, rx_clk //slower clk

);

    int tx_max = 0, rx_max = 0; // tx_max = fclk/baud
    int tx_count = 0, rx_count =0; // to keep count of the clk ticks of faster clock

//calculating tx_max value for different baud rate : tx_max = fclk/baud, rx_max = tx_max/16
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

//generating t_clk for tx_clk
/*
- suppose baud is 9600, then tx_max = 5208, tx_max/2 is 2604 then tx_count goes from 0 to 2603 
- at the clk tick 1, tx_count is at 0 so if block runs and tx_count inc to 1 
- so in 2604 clks ticks, tx_count is at 2603 so if block runs and tx_count inc to 2604
- at the 2605th clk tick, count value is 2604 so else block runs
- t_clk goes from 0 to 1 , similarly after another 2605 clk ticks, t_clk goes from 1 to 0 
- thus we one complete cycle of tx_clk in 2604 + 1 + 2604 + 1 = 5210 clk ticks of faster clk 
*/
    always@(posedge clk) begin
        if(rst) begin
                    tx_count <= 0;
                    t_clk <= 0;
        end
        else begin
            if(tx_count < tx_max/2)  
                begin 
                tx_count <= tx_count + 1;    
                end
            else begin              
                tx_count <= 0;
                t_clk <= ~t_clk; 
            end
        end
    end

//assigning t_clk to tx_clk
    assign tx_clk = t_clk;

endmodule

////////////////////////////////////////////////////////////////////////////

/////interface//////

interface clk_if;

    logic clk, rst;
    logic [16:0] baud;
    logic tx_clk;

endinterface