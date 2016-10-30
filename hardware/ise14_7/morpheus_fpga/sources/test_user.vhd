------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : test_user.vhd
-- Author               : Convers Anthony
-- Date                 : 17.06.2016
--
-- Context              : Morpheus
--
------------------------------------------------------------------------------------------
-- Description : User sw and led test
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

entity test_user is
    Port ( clk_i    : in  STD_LOGIC;
           reset_i 	: in  STD_LOGIC;
           sw_1_i   : in  STD_LOGIC;
           sw_2_i   : in  STD_LOGIC;
           led_1_o  : out  STD_LOGIC;
           led_2_o 	: out  STD_LOGIC);
end test_user;

architecture test_user_arch of test_user is

signal led_1_s     : std_logic;
signal led_2_s     : std_logic;

begin

led_1_o <= led_1_s;
led_2_o <= led_2_s;

process (clk_i, Reset_i)
begin
    if Reset_i='1' then
        led_1_s     <='0';
        led_2_s     <='0';
    elsif rising_edge(clk_i) then
        if sw_1_i='1' then        
            led_1_s    <='1';
		  else
            led_1_s    <='0';
        end if;
		  
		  if sw_2_i='1' then        
            led_2_s    <='1';
		  else
            led_2_s    <='0';
        end if;

    end if;
end process;


end test_user_arch;

