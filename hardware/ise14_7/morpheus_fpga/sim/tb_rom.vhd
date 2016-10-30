--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:45:01 07/11/2016
-- Design Name:   
-- Module Name:   D:/projet_morpheus/fpga_mboard/morpheus_fpga/sim/tb_rom.vhd
-- Project Name:  morpheus_fpga
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: rom_up
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_rom IS
END tb_rom;
 
ARCHITECTURE behavior OF tb_rom IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT rom_up
    PORT(
         clka : IN  std_logic;
         addra : IN  std_logic_vector(11 downto 0);
         douta : OUT  std_logic_vector(23 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clka : std_logic := '0';
   signal addra : std_logic_vector(11 downto 0) := (others => '0');

 	--Outputs
   signal douta : std_logic_vector(23 downto 0);

   -- Clock period definitions
   constant clka_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   U1: rom_up PORT MAP (
          clka => clka,
          addra => addra,
          douta => douta
        );

   -- Clock process definitions
   clka_process :process
   begin
		clka <= '1';
		wait for clka_period/2;
		clka <= '0';
		wait for clka_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 108 ns;	
      
      addra <= x"001";
      wait for clka_period;
      addra <= x"002";
      wait for clka_period;
      addra <= x"003";
      wait for clka_period;
      addra <= x"004";
      wait for clka_period;
      addra <= x"EFF";

      wait for clka_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
