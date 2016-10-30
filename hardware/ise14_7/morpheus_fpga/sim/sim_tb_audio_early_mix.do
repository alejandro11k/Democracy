########################################################
# Simulation script
#######################################################


#create library work
vlib work

#Compile all the modules below it into the library work
vcom -93 -check_synthesis -quiet -work work ./../ipcore_dir/rom_up.vhd
vcom -93 -check_synthesis -quiet -work work ./../ipcore_dir/rom_down.vhd
vcom -93 -check_synthesis -quiet -work work ./../ipcore_dir/fifo_data_2clk.vhd
vcom -93 -check_synthesis -quiet -work work ./../sources/audio_early_mix.vhd


#Compile the test-bench
vcom -93 -quiet tb_audio_early_mix.vhd

#Init simulation 
vsim -t ps tb_audio_early_mix

# Add wave
source wave_tb_audio_early_mix.do

#Start simulation 
#run -all
run 1500us