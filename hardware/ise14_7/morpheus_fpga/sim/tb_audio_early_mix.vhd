--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:18:53 07/12/2016
-- Design Name:   
-- Module Name:   D:/projet_morpheus/fpga_mboard/morpheus_fpga/sim/tb_audio_early_mix.vhd
-- Project Name:  morpheus_fpga
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: audio_early_mix
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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_audio_early_mix IS
END tb_audio_early_mix;
 
ARCHITECTURE behavior OF tb_audio_early_mix IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT audio_early_mix
    PORT(
         clk1_i : IN  std_logic;
         clk2_i : IN  std_logic;
         reset_i : IN  std_logic;
         cmd_gui_on_i : IN  std_logic;
         cmd_syn_on_i : IN  std_logic;
         gui_val_i : IN  std_logic;
         gui_dat_i : IN  std_logic_vector(23 downto 0);
         syn_val_i : IN  std_logic;
         syn_dat_i : IN  std_logic_vector(23 downto 0);
         ear_val_o : OUT  std_logic;
         ear_dat_o : OUT  std_logic_vector(23 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk1_i : std_logic := '0';
   signal clk2_i : std_logic := '0';
   signal reset_i : std_logic := '0';
   signal cmd_gui_on_i : std_logic := '0';
   signal cmd_syn_on_i : std_logic := '0';
   signal gui_val_i : std_logic := '0';
   signal gui_dat_i : std_logic_vector(23 downto 0) := (others => '0');
   signal syn_val_i : std_logic := '0';
   signal syn_dat_i : std_logic_vector(23 downto 0) := (others => '0');

   --Outputs
   signal ear_val_o : std_logic;
   signal ear_dat_o : std_logic_vector(23 downto 0);
   
   --others
   signal enable_data : std_logic := '0';
   signal cpt_s     : std_logic_vector (7 downto 0):= (others => '0');
   constant cpt_end : std_logic_vector (7 downto 0):= conv_std_logic_vector (31, 8);

   -- Clock period definitions
   constant clk1_i_period : time := 10 ns;
   constant clk2_i_period : time := 40 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   U1: audio_early_mix PORT MAP (
          clk1_i => clk1_i,
          clk2_i => clk2_i,
          reset_i => reset_i,
          cmd_gui_on_i => cmd_gui_on_i,
          cmd_syn_on_i => cmd_syn_on_i,
          gui_val_i => gui_val_i,
          gui_dat_i => gui_dat_i,
          syn_val_i => syn_val_i,
          syn_dat_i => syn_dat_i,
          ear_val_o => ear_val_o,
          ear_dat_o => ear_dat_o
        );

   -- Clock process definitions
clk1_i_process :process
   begin
		clk1_i <= '1';
		wait for clk1_i_period/2;
		clk1_i <= '0';
		wait for clk1_i_period/2;
   end process;
   
clk2_i_process :process
   begin
		clk2_i <= '1';
		wait for clk2_i_period/2;
		clk2_i <= '0';
		wait for clk2_i_period/2;
   end process;
   
process (clk1_i, reset_i)
begin
    if reset_i='1' then
        gui_val_i<= '0';
        syn_val_i<= '0';
        cpt_s <= (others=>'0');
    elsif rising_edge(clk1_i) then
        if enable_data='1' then
            if cpt_s=cpt_end then
                cpt_s <= (others=>'0');
                gui_val_i<= '1';
                syn_val_i<= '1';
            else
                cpt_s <= cpt_s + 1;
                gui_val_i<= '0';
                syn_val_i<= '0';
            end if;
        else
            gui_val_i<= '0';
            syn_val_i<= '0';
        end if;
    
    end if;
end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      reset_i <='1';
      wait for 108 ns;
      reset_i <='0';
      wait for clk1_i_period*10;
      gui_dat_i <= x"7fffff";
      syn_dat_i <= x"000010";
      wait for clk1_i_period;
      enable_data <= '1';
      cmd_gui_on_i <= '0';
      cmd_syn_on_i <= '0';
      wait for clk1_i_period*32*10;
      cmd_gui_on_i <= '1';
      wait for clk1_i_period*32*50;
      cmd_syn_on_i <= '1';
      wait for clk1_i_period*32*4096;
      cmd_gui_on_i <= '0';
      wait for clk1_i_period;
      cmd_syn_on_i <= '0';
      
      

      wait for clk1_i_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
