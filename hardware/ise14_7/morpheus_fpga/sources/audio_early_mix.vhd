------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : audio_early_mix.vhd
-- Author               : Convers Anthony
-- Date                 : 11.07.2016
--
-- Context              : Morpheus
--
------------------------------------------------------------------------------------------
-- Description : Earlysound mix
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
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity audio_early_mix is
    Generic (
           Data_length : integer := 24);
    Port ( clk1_i        : in   STD_LOGIC;                   --96MHz
           clk2_i        : in   STD_LOGIC;                   --24MHz
           reset_i       : in   STD_LOGIC;
           cmd_gui_on_i  : in   STD_LOGIC;
           cmd_syn_on_i  : in   STD_LOGIC;
           cmd_gui_low_i : in   STD_LOGIC;
           cmd_syn_sta_i : in   STD_LOGIC_VECTOR (2 downto 0);
           cmd_inc_str_i : in   STD_LOGIC_VECTOR (3 downto 0);
           gui_val_i     : in   STD_LOGIC;
           gui_dat_i     : in   STD_LOGIC_VECTOR (Data_length-1 downto 0);
           syn_val_i     : in   STD_LOGIC;
           syn_dat_i     : in   STD_LOGIC_VECTOR (Data_length-1 downto 0);
           ear_val_o     : out  STD_LOGIC;
           ear_dat_o     : out  STD_LOGIC_VECTOR (Data_length-1 downto 0));
end audio_early_mix;

architecture audio_early_mix_arch of audio_early_mix is

-- signals fifo
signal fin1_rd_en_s    : std_logic;
signal fin1_full_s     : std_logic;
signal fin1_empty_s    : std_logic;
signal fin1_valid_s    : std_logic;

signal fin2_rd_en_s    : std_logic;
signal fin2_full_s     : std_logic;
signal fin2_empty_s    : std_logic;
signal fin2_valid_s    : std_logic;

signal gui_syn_valid_d1_s : std_logic;
signal gui_dat_d1_s  : std_logic_vector (Data_length-1 downto 0);
signal syn_dat_d1_s  : std_logic_vector (Data_length-1 downto 0);
signal gui_syn_valid_d2_s : std_logic;
signal gui_dat_d2_s    : std_logic_vector (Data_length-1 downto 0);
signal syn_dat_d2_s    : std_logic_vector (Data_length-1 downto 0);

signal fout_rd_en_s    : std_logic;
signal fout_full_s     : std_logic;
signal fout_empty_s    : std_logic;
signal fout_valid_s    : std_logic;

signal ear_val_s        : std_logic;
signal ear_dat_s        : std_logic_vector (Data_length-1 downto 0);

-- signals ROM
signal addr_up_s        : std_logic_vector (11 downto 0);
signal data_up_s        : std_logic_vector (Data_length-1 downto 0);
signal addr_down_s      : std_logic_vector (11 downto 0);
signal data_down_s      : std_logic_vector (Data_length-1 downto 0);

-- signals
type state_machine is (IDLE, S1_UP, S2_UP, S3_DOWN, S4_DOWN);
signal state        : state_machine;

--signal cpt_s            : std_logic_vector (11 downto 0);
--constant cpt_tran_1_len : std_logic_vector (11 downto 0):= conv_std_logic_vector (30, 12);
--constant cpt_tran_2_len : std_logic_vector (11 downto 0):= conv_std_logic_vector (1920, 12);

signal cpt_rom_usg       : unsigned (11 downto 0);
signal incr_str_sel      : unsigned (11 downto 0);
signal incr_str_usg      : unsigned (11 downto 0);
constant cst_incr_0      : unsigned (11 downto 0):= to_unsigned (128, 12);    -- increment=max_size_trans/lenght_trans : 3840/30=128 
constant cst_incr_1      : unsigned (11 downto 0):= to_unsigned (64, 12);     -- increment=max_size_trans/lenght_trans : 3840/60=64 
constant cst_incr_2      : unsigned (11 downto 0):= to_unsigned (32, 12);     -- increment=max_size_trans/lenght_trans : 3840/120=32 
constant cst_incr_3      : unsigned (11 downto 0):= to_unsigned (16, 12);     -- increment=max_size_trans/lenght_trans : 3840/240=16 
constant cst_incr_4      : unsigned (11 downto 0):= to_unsigned (8, 12);      -- increment=max_size_trans/lenght_trans : 3840/480=8 
constant cst_incr_5      : unsigned (11 downto 0):= to_unsigned (4, 12);      -- increment=max_size_trans/lenght_trans : 3840/960=4 
constant cst_incr_6      : unsigned (11 downto 0):= to_unsigned (2, 12);      -- increment=max_size_trans/lenght_trans : 3840/1920=2 
constant cst_incr_7      : unsigned (11 downto 0):= to_unsigned (1, 12);      -- increment=max_size_trans/lenght_trans : 3840/3840=1

constant incr_tr1_usg    : unsigned (11 downto 0):= to_unsigned (32, 12);     -- increment=max_size_trans/lenght_trans : 3840/30=128 3840/120=32 
constant decr_tr2_usg    : unsigned (11 downto 0):= to_unsigned (2, 12);      -- decrement=max_size_trans/lenght_trans : 3840/1920=2
constant size_rom_usg    : unsigned (11 downto 0):= to_unsigned (3840, 12);

signal cmd_inc_str_reg1_s : std_logic_vector (3 downto 0);
signal cmd_inc_str_reg2_s : std_logic_vector (3 downto 0);
signal cmd_inc_str_reg3_s : std_logic_vector (3 downto 0);

signal cmd_syn_sta_reg1_s : std_logic_vector (2 downto 0);
signal cmd_syn_sta_reg2_s : std_logic_vector (2 downto 0);
signal cmd_syn_sta_reg3_s : std_logic_vector (2 downto 0);

signal val_reg1_s       : std_logic;
signal res_mult1_s      : std_logic_vector (Data_length*2 downto 0);
signal res_mult2_s      : std_logic_vector (Data_length*2 downto 0);


begin
---------------------------------------------
-- data change clock domain (fifo input and output data)
--fifo input 1 : guitar
Fin1: entity work.fifo_data_2clk port map (
        rst    => reset_i,
        wr_clk => clk1_i,
        rd_clk => clk2_i,
        din    => gui_dat_i,
        wr_en  => gui_val_i,
        rd_en  => fin1_rd_en_s,
        dout   => gui_dat_d1_s,
        full   => fin1_full_s,
        empty  => fin1_empty_s
        );

fin1_valid_s <= not fin1_empty_s;
fin1_rd_en_s <= gui_syn_valid_d1_s;

--fifo input 2 : synthesizer
Fin2: entity work.fifo_data_2clk port map (
        rst    => reset_i,
        wr_clk => clk1_i,
        rd_clk => clk2_i,
        din    => syn_dat_i,
        wr_en  => syn_val_i,
        rd_en  => fin2_rd_en_s,
        dout   => syn_dat_d1_s,
        full   => fin2_full_s,
        empty  => fin2_empty_s
        );

fin2_valid_s <= not fin2_empty_s;
fin2_rd_en_s <= gui_syn_valid_d1_s;

-- read 2 fifo in the same time
gui_syn_valid_d1_s <= fin1_valid_s and fin2_valid_s;

----
--fifo output : earlysound
Fout: entity work.fifo_data_2clk port map (
        rst    => reset_i,
        wr_clk => clk2_i,
        rd_clk => clk1_i,
        din    => ear_dat_s,
        wr_en  => ear_val_s,
        rd_en  => fout_rd_en_s,
        dout   => ear_dat_o,
        full   => fout_full_s,
        empty  => fout_empty_s
        );

fout_valid_s <= not fout_empty_s;
fout_rd_en_s <= fout_valid_s;

ear_val_o    <= fout_valid_s;

---------------------------------------------
-- ROM 1 : table transition up (fade in)
addr_up_s <= std_logic_vector(cpt_rom_usg);

R01: entity work.rom_up port map (
        clka   => clk2_i,
        addra  => addr_up_s,
        douta  => data_up_s
        );

-- ROM 2 : table transition down (fade out)
addr_down_s <= std_logic_vector(cpt_rom_usg);

R02: entity work.rom_down port map (
        clka   => clk2_i,
        addra  => addr_down_s,
        douta  => data_down_s
        );

---------------------------------------------
--earlysound process

process (clk2_i, reset_i)
begin
    if reset_i='1' then
        state <= IDLE;
        cpt_rom_usg     <= (others=>'0');
        ear_val_s       <= '0';
        ear_dat_s       <= (others=>'0');
        val_reg1_s      <= '0';
        res_mult1_s     <= (others=>'0');
        res_mult2_s     <= (others=>'0');
        gui_syn_valid_d2_s <= '0';
        syn_dat_d2_s    <= (others=>'0');
        gui_dat_d2_s    <= (others=>'0');
        incr_str_sel    <= cst_incr_0;
        incr_str_usg    <= cst_incr_0;
        cmd_inc_str_reg1_s <= (others=>'0');
        cmd_inc_str_reg2_s <= (others=>'0');
        cmd_inc_str_reg3_s <= (others=>'0');
        cmd_syn_sta_reg1_s <= (others=>'0');
        cmd_syn_sta_reg2_s <= (others=>'0');
        cmd_syn_sta_reg3_s <= (others=>'0');
    elsif rising_edge(clk2_i) then
        --
        cmd_syn_sta_reg1_s <= cmd_syn_sta_i;    --register to change clock domain
        cmd_syn_sta_reg2_s <= cmd_syn_sta_reg1_s;
        cmd_syn_sta_reg3_s <= cmd_syn_sta_reg2_s;
        
        cmd_inc_str_reg1_s <= cmd_inc_str_i;    --register to change clock domain
        cmd_inc_str_reg2_s <= cmd_inc_str_reg1_s;
        cmd_inc_str_reg3_s <= cmd_inc_str_reg2_s;
        
        if cmd_inc_str_reg3_s="0000" then
            incr_str_sel <= cst_incr_0;
        elsif cmd_inc_str_reg3_s="0001" then
            incr_str_sel <= cst_incr_1;
        elsif cmd_inc_str_reg3_s="0010" then
            incr_str_sel <= cst_incr_2;
        elsif cmd_inc_str_reg3_s="0011" then
            incr_str_sel <= cst_incr_3;
        elsif cmd_inc_str_reg3_s="0100" then
            incr_str_sel <= cst_incr_4;
        elsif cmd_inc_str_reg3_s="0101" then
            incr_str_sel <= cst_incr_5;
        elsif cmd_inc_str_reg3_s="0110" then
            incr_str_sel <= cst_incr_6;
        elsif cmd_inc_str_reg3_s="0111" then
            incr_str_sel <= cst_incr_7;
        else
            incr_str_sel <= cst_incr_2;
        end if;
        
        --
        gui_syn_valid_d2_s <= gui_syn_valid_d1_s;
        syn_dat_d2_s <= syn_dat_d1_s;
        gui_dat_d2_s <= std_logic_vector(signed(gui_dat_d1_s) / 2);
        
        case state is             
            when IDLE =>
                -- idle state : output = audio synthesizer
                cpt_rom_usg     <= (others=>'0');
                val_reg1_s      <= '0';
                incr_str_usg    <= incr_str_sel;
                if gui_syn_valid_d2_s='1' then
                    ear_dat_s <= syn_dat_d2_s;
                    ear_val_s <= '1';
                    -- wait audio guitar is ON (not a silence) and data is a low value.
                    if (cmd_gui_on_i='1') and (cmd_gui_low_i='1') then
                        state <= S1_UP;
                    end if;
                else
                    ear_val_s <= '0';
                end if;
            
            
            when S1_UP =>
                -- state transition 1 (synthesizer -> guitar)
                if gui_syn_valid_d2_s='1' then
                    val_reg1_s <= '1';
                    res_mult1_s <= std_logic_vector(signed(gui_dat_d2_s) * signed('0' & data_up_s));
                    res_mult2_s <= std_logic_vector(signed(syn_dat_d2_s) * signed('0' & data_down_s));
                else
                    val_reg1_s <= '0';
                end if;
                
                if val_reg1_s='1' then
                    ear_val_s <= '1';
                    ear_dat_s <= std_logic_vector(signed(res_mult1_s(47 downto 24)) + signed(res_mult2_s(47 downto 24)));
                    if cpt_rom_usg>=(size_rom_usg-incr_str_usg) then
                        cpt_rom_usg <= size_rom_usg-1;
                        state <= S2_UP;
                    else
                        cpt_rom_usg <= cpt_rom_usg + incr_str_usg;
                        -- wait audio synthesizer is ON (not a silence) or audio guitar is off (silence)
                        if ((cmd_syn_on_i='1') and (cmd_syn_sta_reg3_s(2)='1')) or (cmd_gui_on_i='0') then
                            state <= S3_DOWN;
                        end if;
                    end if;
                else
                    ear_val_s <= '0';
                end if;
                

            when S2_UP =>
                -- state transition 1 end : output = audio guitar
                val_reg1_s      <= '0';
                if gui_syn_valid_d2_s='1' then
                    ear_dat_s <= gui_dat_d2_s;
                    ear_val_s <= '1';
                    -- wait audio synthesizer is ON (not a silence) or audio guitar is off (silence)
                    if ((cmd_syn_on_i='1') and (cmd_syn_sta_reg3_s(2)='1')) or (cmd_gui_on_i='0') then
                        state <= S3_DOWN;
                    end if;
                else
                    ear_val_s <= '0';
                end if;
                
            
            when S3_DOWN =>
                -- state transition 2 (guitar -> synthesizer)
                if gui_syn_valid_d2_s='1' then
                    val_reg1_s <= '1';
                    res_mult1_s <= std_logic_vector(signed(gui_dat_d2_s) * signed('0' & data_up_s));
                    res_mult2_s <= std_logic_vector(signed(syn_dat_d2_s) * signed('0' & data_down_s));
                else
                    val_reg1_s <= '0';
                end if;
                
                if val_reg1_s='1' then
                    ear_val_s <= '1';
                    ear_dat_s <= std_logic_vector(signed(res_mult1_s(47 downto 24)) + signed(res_mult2_s(47 downto 24)));
                    if cpt_rom_usg<decr_tr2_usg then
                        cpt_rom_usg <= (others=>'0');
                        state <= S4_DOWN;
                    else
                        cpt_rom_usg <= cpt_rom_usg - decr_tr2_usg;
                    end if;
                else
                    ear_val_s <= '0';
                end if;
            
            when S4_DOWN =>
                -- state transition 2 end : output = audio synthesizer
                val_reg1_s      <= '0';
                if gui_syn_valid_d2_s='1' then
                    ear_dat_s <= syn_dat_d2_s;
                    ear_val_s <= '1';
                else
                    ear_val_s <= '0';
                end if;
                
                -- wait audio guitar and synthesizer are OFF (a silence)
                if ((cmd_gui_on_i='0') and ((cmd_syn_on_i='0') or (cmd_syn_sta_reg3_s="001"))) then
                    state <= IDLE;
                elsif ((cmd_gui_on_i='1') and (cmd_syn_sta_reg3_s="010")) then  --or wait a new note is detected (synthesizer already on)
                    state <= IDLE;
                end if;
                
            
            when others=>
                state <= IDLE;
        end case;
        
    end if;
end process;


end audio_early_mix_arch;

