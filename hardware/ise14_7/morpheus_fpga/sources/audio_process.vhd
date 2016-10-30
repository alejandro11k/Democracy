------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : audio_process.vhd
-- Author               : Convers Anthony
-- Date                 : 05.07.2016
--
-- Context              : Morpheus
--
------------------------------------------------------------------------------------------
-- Description : Audio processing
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity audio_process is
    Generic (
           Data_length : integer := 24);
    Port ( clk_i            : in   STD_LOGIC;
           reset_i          : in   STD_LOGIC;
           valid_i          : in   STD_LOGIC;
           data_i           : in   STD_LOGIC_VECTOR (Data_length-1 downto 0);
           cmd_1_i          : in   STD_LOGIC;
           cmd_seuil_up_i   : in   STD_LOGIC_VECTOR (11 downto 0);
           cmd_seuil_down_i : in   STD_LOGIC_VECTOR (11 downto 0);
           note_on_o        : out  STD_LOGIC;
           data_low_o       : out  STD_LOGIC;
           test_1_o         : out  STD_LOGIC;
           test_2_o         : out  STD_LOGIC);
end audio_process;

architecture audio_process_arch of audio_process is

signal data_reg_1_s     : std_logic_vector (Data_length-1 downto 0);
signal data_max_s       : std_logic_vector (Data_length-1 downto 0);
signal seuil_up_s       : std_logic_vector (Data_length-1 downto 0);
signal seuil_down_s     : std_logic_vector (Data_length-1 downto 0);
signal valid_reg_1_s    : std_logic;
signal valid_reg_2_s    : std_logic;

signal data_sup_s       : std_logic_vector (7 downto 0);
signal cpt_inf_s        : std_logic_vector (11 downto 0);
constant cpt_inf_max    : std_logic_vector (11 downto 0):= conv_std_logic_vector (536, 12);
signal data_inf_s       : std_logic;
signal note_on_s        : std_logic;
signal data_low_s       : std_logic;


begin

note_on_o <= note_on_s;
data_low_o <= data_low_s;

process (clk_i, reset_i)
begin
    if reset_i='1' then
        valid_reg_1_s   <= '0';
        valid_reg_2_s   <= '0';
        test_1_o        <= '0';
        test_2_o        <= '0';
        data_reg_1_s    <= (others=>'0');
        data_max_s      <= (others=>'0');
        data_sup_s      <= (others=>'0');
        seuil_up_s      <= (others=>'0');
        seuil_down_s    <= (others=>'0');
        cpt_inf_s       <= (others=>'0');
        data_inf_s      <= '0';
        note_on_s       <= '0';
        data_low_s      <= '0';
    elsif rising_edge(clk_i) then
        valid_reg_1_s <= valid_i;
        valid_reg_2_s <= valid_reg_1_s;
        seuil_up_s    <= x"0" & cmd_seuil_up_i & x"00";
        seuil_down_s  <= x"0" & cmd_seuil_down_i & x"00";
        
        if valid_i='1' then
            if data_i(Data_length-1)='1' then
                --valeur negative
                data_reg_1_s(Data_length-2 downto 0) <= (not data_i(Data_length-2 downto 0)) + 1;
                data_reg_1_s(Data_length-1) <= '0';
            else
                --valeur positive
                data_reg_1_s <= data_i;
            end if;
        end if;
        
        if valid_reg_1_s='1' then
            --detection superieur seuil
            if data_reg_1_s >= seuil_up_s then --x"2000"
                data_sup_s <= data_sup_s(6 downto 0) & '1';
                data_low_s <= '0';
            else
                data_sup_s <= data_sup_s(6 downto 0) & '0';
                data_low_s <= '1';
            end if;
            
            --detection inferieur seuil
            if data_reg_1_s >= seuil_down_s then --x"2000"
                cpt_inf_s  <= (others=>'0');
                data_inf_s <= '0';
            else
                if cpt_inf_s = cpt_inf_max then
                    data_inf_s <= '1';
                else
                    cpt_inf_s <= cpt_inf_s + 1;
                end if;
            end if;
            
            --detection max
            if data_reg_1_s > data_max_s then
                data_max_s <= data_reg_1_s;
                test_2_o <= '1';
            else
                test_2_o <= '0';
            end if;
            
        elsif cmd_1_i='1' then
            data_max_s <= (others=>'0');
        end if;
        
        if valid_reg_2_s='1' then
            if data_sup_s="11111111" then
                test_1_o <= '1';
            else
                test_1_o <= '0';
            end if;
            
            --detection note on/off
            if note_on_s='1' then
                if data_inf_s='1' then
                    note_on_s <= '0';
                end if;
            else
                if data_sup_s="11111111" then
                    note_on_s <= '1';
                end if;
            end if;
        
        end if;
        
        
    end if;
end process;


end audio_process_arch;

