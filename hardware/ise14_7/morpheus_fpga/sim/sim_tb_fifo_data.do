########################################################
# Simulation script
#######################################################


#create library work
vlib work

#Compile all the modules below it into the library work
vcom -93 -check_synthesis -quiet -work work ./../ipcore_dir/fifo_data.vhd


#Compile the test-bench
vcom -93 -quiet tb_fifo_data.vhd

#Init simulation 
vsim -t ps tb_fifo_data

# Add wave
source wave_tb_fifo_data.do

#Start simulation 
#run -all
run 500ns