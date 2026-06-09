`include "clk_generator.sv"
`include "uart_tx.sv"
`include "uart_rx.sv"

module uart_top(
    input clk, rst,
    input tx_start, rx_start,
    input [7:0] tx_data,
    input [16:0] baud,
    input [3:0] length,
    input parity_type, parity_en,
    input stop2,
    output tx_done, rx_done, 
    output tx_err, rx_err,
    output [7:0] rx_data 
);

    wire tx_clk, rx_clk;
    wire tx_to_rx;

    clk_generator clk_dut(
        .clk(clk), 
        .rst(rst),
        .baud(baud),
        .tx_clk(tx_clk), 
        .rx_clk(rx_clk) 
    );

    








endmodule