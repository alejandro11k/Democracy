onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_audio_early_mix/clk1_i
add wave -noupdate /tb_audio_early_mix/clk2_i
add wave -noupdate /tb_audio_early_mix/reset_i
add wave -noupdate /tb_audio_early_mix/cmd_gui_on_i
add wave -noupdate /tb_audio_early_mix/cmd_syn_on_i
add wave -noupdate /tb_audio_early_mix/gui_val_i
add wave -noupdate /tb_audio_early_mix/gui_dat_i
add wave -noupdate /tb_audio_early_mix/syn_val_i
add wave -noupdate /tb_audio_early_mix/syn_dat_i
add wave -noupdate /tb_audio_early_mix/ear_val_o
add wave -noupdate /tb_audio_early_mix/ear_dat_o
add wave -noupdate /tb_audio_early_mix/enable_data
add wave -noupdate /tb_audio_early_mix/cpt_s
add wave -noupdate /tb_audio_early_mix/cpt_end
add wave -noupdate -divider U1
add wave -noupdate /tb_audio_early_mix/U1/clk1_i
add wave -noupdate /tb_audio_early_mix/U1/clk2_i
add wave -noupdate /tb_audio_early_mix/U1/reset_i
add wave -noupdate /tb_audio_early_mix/U1/cmd_gui_on_i
add wave -noupdate /tb_audio_early_mix/U1/cmd_syn_on_i
add wave -noupdate /tb_audio_early_mix/U1/gui_val_i
add wave -noupdate /tb_audio_early_mix/U1/gui_dat_i
add wave -noupdate /tb_audio_early_mix/U1/syn_val_i
add wave -noupdate /tb_audio_early_mix/U1/syn_dat_i
add wave -noupdate /tb_audio_early_mix/U1/ear_val_o
add wave -noupdate /tb_audio_early_mix/U1/ear_dat_o
add wave -noupdate /tb_audio_early_mix/U1/fin1_rd_en_s
add wave -noupdate /tb_audio_early_mix/U1/fin1_full_s
add wave -noupdate /tb_audio_early_mix/U1/fin1_empty_s
add wave -noupdate /tb_audio_early_mix/U1/fin1_valid_s
add wave -noupdate /tb_audio_early_mix/U1/fin2_rd_en_s
add wave -noupdate /tb_audio_early_mix/U1/fin2_full_s
add wave -noupdate /tb_audio_early_mix/U1/fin2_empty_s
add wave -noupdate /tb_audio_early_mix/U1/fin2_valid_s
add wave -noupdate /tb_audio_early_mix/U1/gui_syn_valid_d2_s
add wave -noupdate /tb_audio_early_mix/U1/gui_dat_d2_s
add wave -noupdate /tb_audio_early_mix/U1/syn_dat_d2_s
add wave -noupdate /tb_audio_early_mix/U1/fout_rd_en_s
add wave -noupdate /tb_audio_early_mix/U1/fout_full_s
add wave -noupdate /tb_audio_early_mix/U1/fout_empty_s
add wave -noupdate /tb_audio_early_mix/U1/fout_valid_s
add wave -noupdate /tb_audio_early_mix/U1/ear_val_s
add wave -noupdate /tb_audio_early_mix/U1/ear_dat_s
add wave -noupdate /tb_audio_early_mix/U1/addr_up_s
add wave -noupdate /tb_audio_early_mix/U1/data_up_s
add wave -noupdate /tb_audio_early_mix/U1/addr_down_s
add wave -noupdate /tb_audio_early_mix/U1/data_down_s
add wave -noupdate /tb_audio_early_mix/U1/state
add wave -noupdate /tb_audio_early_mix/U1/cpt_rom_usg
add wave -noupdate /tb_audio_early_mix/U1/val_reg1_s
add wave -noupdate /tb_audio_early_mix/U1/res_mult1_s
add wave -noupdate /tb_audio_early_mix/U1/res_mult2_s
add wave -noupdate /tb_audio_early_mix/U1/incr_tr1_usg
add wave -noupdate /tb_audio_early_mix/U1/incr_tr2_usg
add wave -noupdate /tb_audio_early_mix/U1/size_rom_usg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1499878400 ps} {1500006400 ps}
