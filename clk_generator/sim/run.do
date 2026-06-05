vlib work
vlog ../rtl/clk_gen.sv
vlog ../tb/tb_clk_gen.sv
vsim -debugDB -voptargs="+acc" work.tb
add wave -r /tb/*
run -all

view schematic 
add schematic /tb_clk_gen/DUT 