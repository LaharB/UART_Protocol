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

    uart_tx tx_dut(
        .tx_clk(tx_clk), 
        .tx_start(tx_start),
        .rst(rst),
        .tx_data(tx_data),
        .length(length),
        .parity_type(parity_type), 
        .parity_en(parity_en),  
        .stop2(stop2), 
        .tx(tx_to_rx), 
        .tx_done(tx_done), 
        .tx_err(tx_err)
    );

    uart_rx rx_dut(
        .rx_clk(rx_clk), 
        .rx_start(rx_start),
        .rst(rst), 
        .rx(tx_to_rx), 
        .length(length),
        .parity_type(parity_type), 
        .parity_en(parity_en),
        .stop2(stop2),
        .rx_out(rx_out),
        .rx_done(rx_done), 
        .rx_error(rx_err)
    );

endmodule