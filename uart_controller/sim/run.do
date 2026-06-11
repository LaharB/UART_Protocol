vlib work
vlog ../rtl/uart_top.sv 
vlog ../tb/testbench.sv
vsim -debugDB -voptargs="+acc" work.tb
# add wave -r /tb/*
do wave.do
run -all
view schematic
add schematic /tb/DUT
