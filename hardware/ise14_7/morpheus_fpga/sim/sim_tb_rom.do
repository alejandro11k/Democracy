########################################################
# Simulation script
#######################################################


#create library work
vlib work

#Compile all the modules below it into the library work
vcom -93 -check_synthesis -quiet -work work ./../ipcore_dir/rom_up.vhd


#Compile the test-bench
vcom -93 -quiet tb_rom.vhd

#Init simulation 
vsim -t ps tb_rom

# Add wave
source wave_tb_rom.do

#Start simulation 
#run -all
run 500ns