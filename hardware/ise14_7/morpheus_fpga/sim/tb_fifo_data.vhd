--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:27:59 07/04/2016
-- Design Name:   
-- Module Name:   D:/projet_morpheus/fpga_mboard/morpheus_fpga/sim/tb_fifo_data.vhd
-- Project Name:  morpheus_fpga
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fifo_data
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
 
ENTITY tb_fifo_data IS
END tb_fifo_data;
 
ARCHITECTURE behavior OF tb_fifo_data IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fifo_data
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         din : IN  std_logic_vector(23 downto 0);
         wr_en : IN  std_logic;
         rd_en : IN  std_logic;
         dout : OUT  std_logic_vector(23 downto 0);
         full : OUT  std_logic;
         empty : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal din : std_logic_vector(23 downto 0) := (others => '0');
   signal wr_en : std_logic := '0';
   signal rd_en : std_logic := '0';

 	--Outputs
   signal dout : std_logic_vector(23 downto 0);
   signal full : std_logic;
   signal empty : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   U01: fifo_data PORT MAP (
          clk => clk,
          rst => rst,
          din => din,
          wr_en => wr_en,
          rd_en => rd_en,
          dout => dout,
          full => full,
          empty => empty
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      rst <= '1';
      wait for 108 ns;
      rst <= '0';
      wait for clk_period*20;
      din <= x"000001";
      wr_en <= '1';
      wait for clk_period;
      din <= x"000002";
      wait for clk_period;
      din <= x"000003";
      wait for clk_period;
      din <= x"000004";
      wait for clk_period;
      wr_en <= '0';
      wait for clk_period*5;
      rd_en <= '1';
      wait for clk_period*4;
      rd_en <= '0';

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
