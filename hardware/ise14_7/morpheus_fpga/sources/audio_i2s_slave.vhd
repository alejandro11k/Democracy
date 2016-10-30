------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : audio_i2s_slave.vhd
-- Author               : Convers Anthony
-- Date                 : 30.06.2016
--
-- Context              : Morpheus
--
------------------------------------------------------------------------------------------
-- Description : Audio I2S slave interface
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

entity audio_i2s_slave is
    Generic (
           Data_length : integer := 24);
    Port ( clk_i                : in   STD_LOGIC;
           reset_i              : in   STD_LOGIC;
           -- I2S signal
           i2s_bclk_i           : in   STD_LOGIC;
           i2s_lrclk_i          : in   STD_LOGIC;
           i2s_rxdat_i          : in   STD_LOGIC;
           i2s_txdat_o          : out  STD_LOGIC;
           -- to FPGA logic
           rx_valid_left_o      : out  STD_LOGIC;
           rx_data_left_o       : out  STD_LOGIC_VECTOR (Data_length-1 downto 0);
           rx_valid_right_o     : out  STD_LOGIC;
           rx_data_right_o      : out  STD_LOGIC_VECTOR (Data_length-1 downto 0);
           tx_read_left_o       : out  STD_LOGIC;
           tx_valid_left_i      : in   STD_LOGIC;
           tx_data_left_i       : in   STD_LOGIC_VECTOR (Data_length-1 downto 0);
           tx_read_right_o      : out  STD_LOGIC;
           tx_valid_right_i     : in   STD_LOGIC;
           tx_data_right_i      : in   STD_LOGIC_VECTOR (Data_length-1 downto 0));
end audio_i2s_slave;

architecture audio_i2s_slave_arch of audio_i2s_slave is

type state_machine is (IDLE, LEFT_State, RIGHT_State);
signal state        : state_machine;

signal i2s_bclk_delay1_s     : std_logic;
signal i2s_bclk_delay2_s     : std_logic;
signal i2s_bclk_delay3_s     : std_logic;

constant counter_BIT_C       : std_logic_vector (5 downto 0):= conv_std_logic_vector (Data_length-1, 6);
signal counter_s             : std_logic_vector (5 downto 0);

signal i2s_txdat_s           : std_logic;
signal i2s_lrclk_delay_s     : std_logic;
signal rx_data_l_s           : std_logic_vector (Data_length-1 downto 0);
signal rx_data_r_s           : std_logic_vector (Data_length-1 downto 0);
signal tx_data_l_s           : std_logic_vector (Data_length-1 downto 0);
signal tx_data_r_s           : std_logic_vector (Data_length-1 downto 0);



begin

i2s_txdat_o <= i2s_txdat_s;

process (clk_i, reset_i)
begin
    if reset_i='1' then
        i2s_bclk_delay1_s   <= '0';
        i2s_bclk_delay2_s   <= '0';
        i2s_bclk_delay3_s   <= '0';
        i2s_lrclk_delay_s   <= '0';
        state               <= IDLE;
        Counter_s           <= (others=>'0');
        rx_data_l_s         <= (others=>'0');
        rx_data_r_s         <= (others=>'0');
        rx_data_left_o      <= (others=>'0');
        rx_data_right_o     <= (others=>'0');
        rx_valid_left_o     <= '0';
        rx_valid_right_o    <= '0';
        i2s_txdat_s         <= '0';
        tx_data_l_s         <= (others=>'0');
        tx_data_r_s         <= (others=>'0');
        tx_read_left_o      <= '0';
        tx_read_right_o     <= '0';
        
    elsif rising_edge(clk_i) then
        rx_valid_left_o  <= '0';
        rx_valid_right_o <= '0';
        tx_read_left_o   <= '0';
        tx_read_right_o  <= '0';
        
        i2s_bclk_delay1_s <= i2s_bclk_i;
        i2s_bclk_delay2_s <= i2s_bclk_delay1_s;
        i2s_bclk_delay3_s <= i2s_bclk_delay2_s;
        
        if i2s_bclk_delay2_s='1' and i2s_bclk_delay3_s='0' then
            i2s_lrclk_delay_s <= i2s_lrclk_i;
            case state is             
                when IDLE =>
                    Counter_s <= (others=>'0');
                    if i2s_lrclk_i='0' and i2s_lrclk_delay_s='1' then
                        --left channel
                        state <= LEFT_State;
                        if tx_valid_left_i='1' then
                            tx_data_l_s <= tx_data_left_i;
                            tx_read_left_o <= '1';
                        else
                            tx_data_l_s <= (others=>'0');
                        end if;
                    elsif i2s_lrclk_i='1' and i2s_lrclk_delay_s='0' then
                        --right channel
                        state <= RIGHT_State;
                        if tx_valid_right_i='1' then
                            tx_data_r_s <= tx_data_right_i;
                            tx_read_right_o <= '1';
                        else
                            tx_data_r_s <= (others=>'0');
                        end if;
                    end if;
                    
                    
                when LEFT_State =>
                    --left channel RX
                    if Counter_s=counter_BIT_C then
                        state <= IDLE;
                        rx_data_left_o <= rx_data_l_s(Data_length-2 downto 0) & i2s_rxdat_i;
                        rx_valid_left_o <= '1';
                    else
                        Counter_s <= Counter_s+1;
                        rx_data_l_s <= rx_data_l_s(Data_length-2 downto 0) & i2s_rxdat_i;
                    end if;
                    
                when RIGHT_State =>
                    --right channel RX
                    if Counter_s=counter_BIT_C then
                        state <= IDLE;
                        rx_data_right_o <= rx_data_r_s(Data_length-2 downto 0) & i2s_rxdat_i;
                        rx_valid_right_o <= '1';
                    else
                        Counter_s <= Counter_s+1;
                        rx_data_r_s <= rx_data_r_s(Data_length-2 downto 0) & i2s_rxdat_i;
                    end if;
                
                
                when others=>
                    state <= IDLE;
            end case;
            
        elsif i2s_bclk_delay2_s='0' and i2s_bclk_delay3_s='1' then
            case state is 
                when IDLE =>
                    i2s_txdat_s <= '0';
                    
                when LEFT_State =>
                    --left channel TX
                    i2s_txdat_s <= tx_data_l_s(Data_length-1);
                    tx_data_l_s <= tx_data_l_s(Data_length-2 downto 0) & '0';
                    
                when RIGHT_State =>
                    --right channel TX
                    i2s_txdat_s <= tx_data_r_s(Data_length-1);
                    tx_data_r_s <= tx_data_r_s(Data_length-2 downto 0) & '0';
                                      
            end case;
            
        end if;
        
    end if;
end process;


end audio_i2s_slave_arch;

