vlib work
vlog ../rtl/clk_gen.sv
vlog ../tb/clk_gen.sv
vsim -debugDB -voptargs="+acc" work.tb_clk_gen.sv
add wave -r *
run -all

view schematic 
add schematic /tb_clk_gen/DUT 