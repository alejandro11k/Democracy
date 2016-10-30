------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : spi_slave.vhd
-- Author               : Convers Anthony
-- Date                 : 17.06.2016
--
-- Context              : Morpheus
--
------------------------------------------------------------------------------------------
-- Description : Spi slave
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

entity spi_slave is
    Generic (   
 	    Address_Length : integer := 8;
 	    Data_length : integer := 32); 
    Port ( 
        clk_i : in  STD_LOGIC;
        reset_i : in  STD_LOGIC;
        -- SPI signal
        spi_nCS_i       : in std_logic;                         
        spi_SCK_i       : in std_logic;                               
        spi_mosi_i      : in std_logic;                             
        spi_miso_o      : out std_logic;  
        -- to FPGA logic
        Read_Request_o  : out std_logic;
        Address_o       : out std_logic_vector (Address_Length-1 downto 0);
        Write_Request_o : out std_logic;
        Write_Data_o    : out std_logic_vector (Data_length-1 downto 0);        
        Read_Data_i     : in std_logic_vector (Data_length-1 downto 0));
end spi_slave;

architecture spi_slave_arch of spi_slave is


type state_machine is (IDLE, ADD_State, READ_State, WRITE_State, READ_Request_State);
signal state        : state_machine;
signal Read_s       : std_logic;
signal Address_s    : std_logic_vector (Address_Length-1 downto 0);
signal Counter_s    : std_logic_vector (5 downto 0);
signal Read_Data_s  : std_logic_vector (Data_length-2 downto 0);
signal Write_Data_s : std_logic_vector (Data_length-1 downto 0);

signal spi_miso_s           : std_logic;
signal spi_CLK_rising_s     : std_logic;
signal spi_CLK_falling_s    : std_logic;
signal spi_CLK_delay1_s     : std_logic;
signal spi_CLK_delay2_s     : std_logic;
signal spi_CLK_delay3_s     : std_logic;
constant counter_ADD_C      : std_logic_vector (5 downto 0):= conv_std_logic_vector (Address_Length-1, 6);
constant counter_DATA_C     : std_logic_vector (5 downto 0):= conv_std_logic_vector (Data_length-1, 6);

begin


spi_miso_o <= spi_miso_s;

process (clk_i, reset_i)
begin
    if reset_i='1' then
        spi_CLK_delay1_s     <='0';
        spi_CLK_delay2_s     <='0';
        spi_CLK_delay3_s     <='0';
        spi_CLK_rising_s    <='0';
        spi_CLK_falling_s   <='0';
    elsif rising_edge(clk_i) then
        spi_CLK_rising_s    <='0';
        spi_CLK_falling_s   <='0';
        spi_CLK_delay1_s <= spi_SCK_i;
        spi_CLK_delay2_s <= spi_CLK_delay1_s;
        spi_CLK_delay3_s <= spi_CLK_delay2_s;
        if spi_CLK_delay2_s='1' and spi_CLK_delay3_s='0' then        
            spi_CLK_rising_s    <='1';
        end if;
        
        if spi_CLK_delay2_s='0' and spi_CLK_delay3_s='1' then          
            spi_CLK_falling_s   <='1';
        end if;
    end if;
end process;




process (reset_i,spi_nCS_i,clk_i)
begin
if reset_i='1' or spi_nCS_i='1' then
    spi_miso_s      <= 'Z';
    state           <= IDLE; 
    Read_s          <= '0'; 
    Address_s       <= (others=>'0'); 
    Counter_s       <= (others=>'0');
    Read_Request_o  <= '0'; 
    Read_Data_s     <= (others=>'0'); 
    Write_Data_s    <= (others=>'0');
    Address_o       <= (others=>'0');
    Write_Request_o <= '0'; 
    Write_Data_o    <= (others=>'0');     
elsif rising_edge (clk_i) then
    Write_Request_o <= '0';
    Read_Request_o  <= '0';
    if spi_CLK_rising_s='1' then      
        case state is             
            when IDLE =>                        
                --Write_Request_o     <= '0';                                       
                --if spi_mosi_i='1' then
                --    Read_s  <= '1';
              --  else
                    Read_s  <= '0';                
              --  end if;                                                
                Address_s <= Address_s(Address_Length-2 downto 0) & spi_mosi_i;
                Counter_s <= Counter_s+1;
                state <= ADD_State;  
                
            when ADD_State =>
                Counter_s <= Counter_s+1;
                Address_s <= Address_s(Address_Length-2 downto 0) & spi_mosi_i;
                if Counter_s= counter_ADD_C then
                    if Read_s='1' then
                        state           <= READ_Request_State;
                        Read_Request_o  <= '1';
                        Address_o       <= Address_s(Address_Length-2 downto 0) & spi_mosi_i;
                    else
                        state <= WRITE_State;    
                    end if;
                    Counter_s <= (others=>'0');
                end if;
            when WRITE_State =>   
                Write_Data_s    <=  Write_Data_s(  Data_length-2 downto 0) & spi_mosi_i;
                Counter_s       <= Counter_s+1;    
                if Counter_s= counter_DATA_C then
                    Counter_s       <= (others=>'0');
                    state           <= IDLE;
                    Address_o       <= Address_s;
                    Write_Request_o <= '1';
                    Write_Data_o    <=Write_Data_s(  Data_length-2 downto 0) & spi_mosi_i;
                end if;
            when READ_Request_State=>                     
                
            when READ_State=>
                if Counter_s= counter_DATA_C then
                    Counter_s   <= (others=>'0');
                    state       <= IDLE;
                end if;                    
            when others=>
                state           <= IDLE;
        end case;
    
    elsif spi_CLK_falling_s='1' then   
        case state is 
            when IDLE =>
                spi_miso_s      <= 'Z';
                
            when ADD_State =>                    
            when WRITE_State =>                    
            
            when READ_Request_State=> -- also 1st bit out                        
                Read_Request_o  <= '1';
                Read_Data_s     <= Read_Data_i(Data_length-2 downto 0);
                spi_miso_s      <= Read_Data_i(Data_length-1);
                state           <= READ_State;
                Counter_s       <= Counter_s+1;
        
            when READ_State=>
                -- Read_Request_o  <= '0';                       
                spi_miso_s      <= Read_Data_s(Read_Data_s'length-1);
                Read_Data_s     <= Read_Data_s(Read_Data_s'length-2 downto 0) & '0';                    
                Counter_s       <= Counter_s+1;
                -- if Counter_s= counter_DATA_C then
                    -- Counter_s   <= (others=>'0');
                    -- state       <= IDLE;
                -- end if;                    
        end case;
    end if;
end if;
end process;
    
end spi_slave_arch;

