vlib work
vlog ../rtl/uart_top.sv ../tb/testbench.sv
vsim -debugDB -voptargs="+acc" work.tb
add wave -r /tb/*
run -all
view schematic
add schematic /tb/DUT
