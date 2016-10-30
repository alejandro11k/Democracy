------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : top_mboard.vhd
-- Author               : Convers Anthony
-- Date                 : 17.06.2016
--
-- Context              : Morpheus
--
------------------------------------------------------------------------------------------
-- Description : Top design
--   
------------------------------------------------------------------------------------------
-- Dependencies : 
--   
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver    Date        Engineer      Comments
-- 0.0    See header  ACS           Initial version.
--
------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity top_mboard is
    Port ( FPGA_clock_24MHz_i   : in  STD_LOGIC;
           FPGA_nReset_i        : in  STD_LOGIC;
           --SPI
           SPI_bus_sclk_i       : in  STD_LOGIC;
           SPI_bus_mosi_i       : in  STD_LOGIC;
           SPI_bus_miso_o       : inout STD_LOGIC;
           SPI_cs_i             : in  STD_LOGIC;
           --PCM
           PCM_dout_rpi_i       : in  STD_LOGIC;
           PCM_din_rpi_o        : out STD_LOGIC;
           PCM_fs_rpi_o         : out STD_LOGIC;
           PCM_clk_rpi_o        : out STD_LOGIC;
           PCM_clk_cirrus_i     : in  STD_LOGIC;
           PCM_fs_cirrus_i      : in  STD_LOGIC;
           PCM_din_cirrus_i     : in  STD_LOGIC;
           PCM_dout_cirrus_o    : out STD_LOGIC;
           --header (use for debug)
           FPGA_header1_o       : out STD_LOGIC;
           FPGA_header2_o       : out STD_LOGIC;
           FPGA_header3_o       : out STD_LOGIC;
           FPGA_header4_o       : out STD_LOGIC;
           FPGA_header5_o       : out STD_LOGIC;
           FPGA_header6_o       : out STD_LOGIC;
           FPGA_header7_o       : out STD_LOGIC;
           FPGA_header8_o       : out STD_LOGIC;
           --User
           SW_user_1_i          : in  STD_LOGIC;
           SW_user_2_i          : in  STD_LOGIC;
           LED_user_1_o         : out STD_LOGIC;
           LED_user_2_o         : out STD_LOGIC);
end top_mboard;

architecture top_mboard_arch of top_mboard is

signal clk_24MHz_s       : std_logic;
signal clk_96MHz_s       : std_logic;
signal reset_s           : std_logic;

signal LED_user_1_s      : std_logic;
signal LED_user_2_s      : std_logic;

signal write_en_s        : std_logic;
signal address_s         : std_logic_vector( 3 downto 0); 
signal data_out_s        : std_logic_vector( 3 downto 0);

signal REG_A_s           : std_logic_vector( 3 downto 0); 
signal REG_B_s           : std_logic_vector( 3 downto 0); 
signal REG_C_s           : std_logic_vector( 3 downto 0); 
signal REG_D_s           : std_logic_vector( 3 downto 0);
signal REG_E_s           : std_logic_vector( 3 downto 0); 
signal REG_F_s           : std_logic_vector( 3 downto 0); 
signal REG_G_s           : std_logic_vector( 3 downto 0); 
signal REG_H_s           : std_logic_vector( 3 downto 0);
signal REG_I_s           : std_logic_vector( 3 downto 0); 
signal REG_J_s           : std_logic_vector( 3 downto 0); 
signal REG_K_s           : std_logic_vector( 3 downto 0); 
signal REG_L_s           : std_logic_vector( 3 downto 0);
signal REG_M_s           : std_logic_vector( 3 downto 0); 
signal REG_N_s           : std_logic_vector( 3 downto 0); 
signal REG_O_s           : std_logic_vector( 3 downto 0); 
signal REG_P_s           : std_logic_vector( 3 downto 0);
signal led_1_reg_s       : std_logic;
signal led_2_reg_s       : std_logic;
signal sel_audio_src     : std_logic_vector( 1 downto 0);

--signal PCM
signal PCM_dout_fpga_s   : std_logic;

--signal i2s slave
signal rx1_val_l_s       : std_logic;
signal rx1_dat_l_s       : std_logic_vector(23 downto 0);
signal rx1_val_r_s       : std_logic;
signal rx1_dat_r_s       : std_logic_vector(23 downto 0);
signal rx2_val_l_s       : std_logic;
signal rx2_dat_l_s       : std_logic_vector(23 downto 0);
signal rx2_val_r_s       : std_logic;
signal rx2_dat_r_s       : std_logic_vector(23 downto 0);
signal tx_read_l_s       : std_logic;
signal tx_val_l_s        : std_logic;
signal tx_dat_l_s        : std_logic_vector(23 downto 0);
signal tx_read_r_s       : std_logic;
signal tx_val_r_s        : std_logic;
signal tx_dat_r_s        : std_logic_vector(23 downto 0);

--signal fifo 1 audio (left) 
signal fifo1_din_s        : std_logic_vector(23 downto 0);
signal fifo1_wr_en_s      : std_logic;
signal fifo1_rd_en_s      : std_logic;
signal fifo1_dout_s       : std_logic_vector(23 downto 0);
signal fifo1_full_s       : std_logic;
signal fifo1_empty_s      : std_logic;
signal fifo1_valid_s      : std_logic;

--signal fifo 2 audio (left) 
signal fifo2_din_s        : std_logic_vector(23 downto 0);
signal fifo2_wr_en_s      : std_logic;
signal fifo2_rd_en_s      : std_logic;
signal fifo2_dout_s       : std_logic_vector(23 downto 0);
signal fifo2_full_s       : std_logic;
signal fifo2_empty_s      : std_logic;
signal fifo2_valid_s      : std_logic;

--signal fifo 3 audio (left) 
signal fifo3_din_s        : std_logic_vector(23 downto 0);
signal fifo3_wr_en_s      : std_logic;
signal fifo3_rd_en_s      : std_logic;
signal fifo3_dout_s       : std_logic_vector(23 downto 0);
signal fifo3_full_s       : std_logic;
signal fifo3_empty_s      : std_logic;
signal fifo3_valid_s      : std_logic;

--signal audio test
signal cmd_1_s            : std_logic;
signal cmd_gui_seuil_up_s : std_logic_vector(11 downto 0);
signal cmd_gui_seuil_down_s   : std_logic_vector(11 downto 0);
signal cmd_syn_seuil_up_s : std_logic_vector(11 downto 0);
signal cmd_syn_seuil_down_s   : std_logic_vector(11 downto 0);
signal cmd_incr_start_s   : std_logic_vector(3 downto 0);
signal cmd_synt_status_s  : std_logic_vector(2 downto 0);
signal test_1_s           : std_logic;
signal test_2_s           : std_logic;
signal test_3_s           : std_logic;
signal test_4_s           : std_logic;
signal test_led_s         : std_logic;
signal test_gui_note_on_s : std_logic;
signal test_syn_note_on_s : std_logic;
signal test_gui_low_s     : std_logic;
signal test_syn_low_s     : std_logic;

--signal earlysound mix
signal cmd_gui_on_s       : std_logic;
signal cmd_syn_on_s       : std_logic;
signal cmd_gui_low_s      : std_logic;
signal ear_val_s          : std_logic;
signal ear_dat_s          : std_logic_vector(23 downto 0);

begin

--IBUFG_24M : IBUFG
--   generic map (
--      IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--      IOSTANDARD => "DEFAULT")
--   port map (
--      O => clk_24MHz_s, -- Clock buffer output
--      I => FPGA_clock_24MHz_i  -- Clock buffer input (connect directly to top-level port)
--   );	
	
reset_s <= not FPGA_nReset_i;

C01 : entity work.clk_wiz port map(
    -- Clock in ports
    CLK_IN1 => FPGA_clock_24MHz_i,
    -- Clock out ports
    CLK_OUT1 => clk_96MHz_s,
    CLK_OUT2 => clk_24MHz_s,
    -- Status and control signals
    RESET  => reset_s,
    LOCKED => open);

---------------------------------------------
--PCM loopback

--process (clk_24MHz_s, reset_s)
--begin
--    if reset_s='1' then
--        PCM_clk_rpi_o       <= '0';
--        PCM_fs_rpi_o        <= '0';
--        PCM_din_rpi_o       <= '0';
--        PCM_dout_cirrus_o   <= '0';
--
--    elsif rising_edge(clk_24MHz_s) then
--    
--        PCM_clk_rpi_o       <= PCM_clk_cirrus_i;
--        PCM_fs_rpi_o        <= PCM_fs_cirrus_i;
--        PCM_din_rpi_o       <= PCM_din_cirrus_i;
--        PCM_dout_cirrus_o   <= PCM_dout_rpi_i;
--      
--    end if ;
--end process;

PCM_clk_rpi_o       <= PCM_clk_cirrus_i;
PCM_fs_rpi_o        <= PCM_fs_cirrus_i;
PCM_din_rpi_o       <= PCM_din_cirrus_i;
PCM_dout_cirrus_o   <= PCM_dout_fpga_s;     --PCM_dout_rpi_i

A01: entity work.audio_i2s_2slave generic map (
        Data_length     => 24)
    port map (
        clk_i               => clk_96MHz_s,
        reset_i             => reset_s,
        i2s_bclk_i          => PCM_clk_cirrus_i,
        i2s_lrclk_i         => PCM_fs_cirrus_i,
        i2s_rx1dat_i        => PCM_din_cirrus_i,
        i2s_rx2dat_i        => PCM_dout_rpi_i,
        i2s_txdat_o         => PCM_dout_fpga_s,
        rx1_valid_left_o    => rx1_val_l_s,
        rx1_data_left_o     => rx1_dat_l_s,
        rx1_valid_right_o   => rx1_val_r_s,
        rx1_data_right_o    => rx1_dat_r_s,
        rx2_valid_left_o    => rx2_val_l_s,
        rx2_data_left_o     => rx2_dat_l_s,
        rx2_valid_right_o   => rx2_val_r_s,
        rx2_data_right_o    => rx2_dat_r_s,
        tx_read_left_o      => tx_read_l_s,
        tx_valid_left_i     => tx_val_l_s,
        tx_data_left_i      => tx_dat_l_s,
        tx_read_right_o     => tx_read_r_s,
        tx_valid_right_i    => tx_val_r_s,
        tx_data_right_i     => tx_dat_r_s
        );

tx_val_r_s <= '0';
tx_dat_r_s <= (others=>'0');

-- Audio <-> Fifo connection
fifo1_wr_en_s   <= rx1_val_l_s;
fifo1_din_s     <= rx1_dat_l_s;
fifo2_wr_en_s   <= rx2_val_l_s;
fifo2_din_s     <= rx2_dat_l_s;
fifo3_wr_en_s   <= ear_val_s;
fifo3_din_s     <= ear_dat_s;

fifo1_rd_en_s   <= tx_read_l_s;
fifo1_valid_s   <= not fifo1_empty_s;
fifo2_rd_en_s   <= tx_read_l_s;
fifo2_valid_s   <= not fifo2_empty_s;
fifo3_rd_en_s   <= tx_read_l_s;
fifo3_valid_s   <= not fifo3_empty_s;

--tx_val_l_s      <= fifo1_valid_s when en_loopbk_s='1' else fifo2_valid_s;
--tx_dat_l_s      <= fifo1_dout_s when en_loopbk_s='1' else fifo2_dout_s;

tx_val_l_s <= fifo1_valid_s when sel_audio_src="01" else    --audio from cirrus (loopback)
              fifo3_valid_s when sel_audio_src="10" else    --audio from earlysound
              fifo2_valid_s;                                --audio from raspberry (default)

tx_dat_l_s <= fifo1_dout_s when sel_audio_src="01" else    --audio from cirrus (loopback)
              fifo3_dout_s when sel_audio_src="10" else    --audio from earlysound
              fifo2_dout_s;                                --audio from raspberry (default)


-- fifo 1 : audio from cirrus
F01: entity work.fifo_data port map (
        clk   => clk_96MHz_s,
        rst   => reset_s,
        din   => fifo1_din_s,
        wr_en => fifo1_wr_en_s,
        rd_en => fifo1_rd_en_s,
        dout  => fifo1_dout_s,
        full  => fifo1_full_s,
        empty => fifo1_empty_s
        );

-- fifo 2 : audio from raspberry
F02: entity work.fifo_data port map (
        clk   => clk_96MHz_s,
        rst   => reset_s,
        din   => fifo2_din_s,
        wr_en => fifo2_wr_en_s,
        rd_en => fifo2_rd_en_s,
        dout  => fifo2_dout_s,
        full  => fifo2_full_s,
        empty => fifo2_empty_s
        );

-- fifo 3 : audio from earlysound
F03: entity work.fifo_data port map (
        clk   => clk_96MHz_s,
        rst   => reset_s,
        din   => fifo3_din_s,
        wr_en => fifo3_wr_en_s,
        rd_en => fifo3_rd_en_s,
        dout  => fifo3_dout_s,
        full  => fifo3_full_s,
        empty => fifo3_empty_s
        );

---------------------------------------------
-- audio test
T01: entity work.audio_process generic map (
        Data_length     => 24)
    port map (
        clk_i            => clk_96MHz_s,
        reset_i          => reset_s,
        valid_i          => rx1_val_l_s,
        data_i           => rx1_dat_l_s,
        cmd_1_i          => cmd_1_s,
        cmd_seuil_up_i   => cmd_gui_seuil_up_s,
        cmd_seuil_down_i => cmd_gui_seuil_down_s,
        note_on_o        => test_gui_note_on_s,
        data_low_o       => test_gui_low_s,
        test_1_o         => test_1_s,
        test_2_o         => test_2_s
        );

T02: entity work.audio_process generic map (
        Data_length     => 24)
    port map (
        clk_i            => clk_96MHz_s,
        reset_i          => reset_s,
        valid_i          => rx2_val_l_s,
        data_i           => rx2_dat_l_s,
        cmd_1_i          => cmd_1_s,
        cmd_seuil_up_i   => cmd_syn_seuil_up_s,
        cmd_seuil_down_i => cmd_syn_seuil_down_s,
        note_on_o        => test_syn_note_on_s,
        data_low_o       => test_syn_low_s,
        test_1_o         => test_3_s,
        test_2_o         => test_4_s
        );


test_led_s <= test_1_s or test_2_s;

-- header connection (use for debug)
FPGA_header1_o <= test_gui_note_on_s;
FPGA_header2_o <= test_syn_note_on_s;
FPGA_header3_o <= test_led_s;
FPGA_header4_o <= test_3_s or test_4_s;
FPGA_header5_o <= test_gui_low_s;
FPGA_header6_o <= test_syn_low_s;
FPGA_header7_o <= cmd_synt_status_s(2);
FPGA_header8_o <= (not cmd_synt_status_s(2)) and cmd_synt_status_s(1) and cmd_synt_status_s(0);

-- audio earlysound
cmd_gui_on_s <= test_gui_note_on_s;
cmd_syn_on_s <= test_syn_note_on_s;
cmd_gui_low_s <= test_gui_low_s;

E01: entity work.audio_early_mix generic map (
        Data_length     => 24)
    port map (
        clk1_i           => clk_96MHz_s,
        clk2_i           => clk_24MHz_s,
        reset_i          => reset_s,
        cmd_gui_on_i     => cmd_gui_on_s,
        cmd_syn_on_i     => cmd_syn_on_s,
        cmd_gui_low_i    => cmd_gui_low_s,
        cmd_syn_sta_i    => cmd_synt_status_s,
        cmd_inc_str_i    => cmd_incr_start_s,
        gui_val_i        => rx1_val_l_s,
        gui_dat_i        => rx1_dat_l_s,
        syn_val_i        => rx2_val_l_s,
        syn_dat_i        => rx2_dat_l_s,
        ear_val_o        => ear_val_s,
        ear_dat_o        => ear_dat_s
        );


---------------------------------------------
LED_user_1_o <= LED_user_1_s and led_1_reg_s and (not test_syn_note_on_s);
LED_user_2_o <= LED_user_2_s and led_2_reg_s and (not test_gui_note_on_s);


U1: entity work.test_user port map (
	clk_i       => clk_96MHz_s,
	reset_i     => reset_s,
	sw_1_i 	    => SW_user_1_i,
	sw_2_i 	    => SW_user_2_i,
	led_1_o 	=> LED_user_1_s,
	led_2_o     => LED_user_2_s
    );


U2: entity work.spi_slave generic map (
        Address_Length  => 4,
        Data_length     => 4)
    port map (
        clk_i           => clk_96MHz_s,
        reset_i         => reset_s,
        spi_nCS_i 	    => SPI_cs_i,
        spi_SCK_i 	    => SPI_bus_sclk_i,
        spi_mosi_i 	    => SPI_bus_mosi_i,
        spi_miso_o      => SPI_bus_miso_o,
        Read_Request_o 	=> open,
        Address_o 	    => address_s,
        Write_Request_o	=> write_en_s,
        Write_Data_o    => data_out_s,
        Read_Data_i     => (others=>'0')
        );


process (clk_96MHz_s, reset_s)
begin
    if reset_s='1' then      
      REG_A_s <= (others=>'0');
      REG_B_s <= (others=>'0');
      REG_C_s <= (others=>'0');
      REG_D_s <= "0000";        --init guitar seuil_up (lsb)
      REG_E_s <= "0011";        --init guitar seuil_up (msb)
      REG_F_s <= "0100";        --init guitar seuil_down
      REG_G_s <= "0000";        --init synth seuil_up (lsb)
      REG_H_s <= "0001";        --init synth seuil_up (msb)
      REG_I_s <= "0100";        --init synth seuil_down
      REG_J_s <= "0000";        --init increment start
      REG_K_s <= (others=>'0');
      REG_L_s <= (others=>'0');
      REG_M_s <= (others=>'0');
      REG_N_s <= (others=>'0');
      REG_O_s <= (others=>'0');
      REG_P_s <= (others=>'0');
    elsif rising_edge(clk_96MHz_s) then
      if write_en_s='1' then
--        if address_s(3)='1' then
--          REG_A_s <= (others=>'0');
--          REG_B_s <= (others=>'0');
--          REG_C_s <= (others=>'0');
--          REG_D_s <= (others=>'0');
--          REG_E_s <= (others=>'0');
--          REG_F_s <= (others=>'0');
--          REG_G_s <= (others=>'0');
--          REG_H_s <= (others=>'0');
--        else  
          case address_s(3 downto 0) is
            when "0000" => REG_A_s <= data_out_s;   --0
            when "0001" => REG_B_s <= data_out_s;   --1
            when "0010" => REG_C_s <= data_out_s;   --2
            when "0011" => REG_D_s <= data_out_s;   --3
            when "0100" => REG_E_s <= data_out_s;   --4
            when "0101" => REG_F_s <= data_out_s;   --5
            when "0110" => REG_G_s <= data_out_s;   --6
            when "0111" => REG_H_s <= data_out_s;   --7
            when "1000" => REG_I_s <= data_out_s;   --8
            when "1001" => REG_J_s <= data_out_s;   --9
            when "1010" => REG_K_s <= data_out_s;   --10
            when "1011" => REG_L_s <= data_out_s;   --11
            when "1100" => REG_M_s <= data_out_s;   --12
            when "1101" => REG_N_s <= data_out_s;   --13
            when "1110" => REG_O_s <= data_out_s;   --14
            when "1111" => REG_P_s <= data_out_s;   --15
            when others=> null;
          end case;
--        end if;
      end if;
    end if ;
end process;

sel_audio_src <= REG_A_s(1 downto 0);
led_1_reg_s <= not REG_B_s(0);
led_2_reg_s <= not REG_B_s(1);

cmd_1_s              <= REG_C_s(0);
cmd_gui_seuil_up_s   <= REG_E_s & REG_D_s & "0000";
cmd_gui_seuil_down_s <= "0000" & REG_F_s & "0000";
cmd_syn_seuil_up_s   <= "0000" & REG_H_s & REG_G_s;
cmd_syn_seuil_down_s <= "0000" & "0000" & REG_I_s;
cmd_incr_start_s     <= REG_J_s;
cmd_synt_status_s    <= REG_K_s(2 downto 0);


end top_mboard_arch;

