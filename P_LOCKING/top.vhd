--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:02:23 10/06/2013
-- Design Name:   
-- Module Name:   C:/Users/denis/MIC2013/P1/top.vhd
-- Project Name:  P1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: P1
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.math_real.all ;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY top IS
END top;
 
ARCHITECTURE behavior OF top IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT P1
    PORT(
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         SDATA : IN  std_logic;
         CSn : OUT  std_logic;
         SCLK : OUT  std_logic;
         AN0 : OUT  std_logic;
         AN1 : OUT  std_logic;
         AN2 : OUT  std_logic;
         AN3 : OUT  std_logic;
         CA : OUT  std_logic;
         CB : OUT  std_logic;
         CC : OUT  std_logic;
         CD : OUT  std_logic;
         CE : OUT  std_logic;
         CF : OUT  std_logic;
         CG : OUT  std_logic
        );
    END COMPONENT;
	 
	 
	 
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';
   signal SDATA : std_logic := '0';

 	--Outputs
   signal CSn : std_logic;
   signal SCLK : std_logic;
   signal AN0 : std_logic;
   signal AN1 : std_logic;
   signal AN2 : std_logic;
   signal AN3 : std_logic;
   signal CA : std_logic;
   signal CB : std_logic;
   signal CC : std_logic;
   signal CD : std_logic;
   signal CE : std_logic;
   signal CF : std_logic;
   signal CG : std_logic;
   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
 
 constant F : real := 20000.0 ;

signal ENTRADA_real : real := 0.0 ;
Signal senal,t,ruido : real := 0.0 ;

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: P1 PORT MAP (
          CLK => CLK,
          RESET => RESET,
          SDATA => SDATA,
          CSn => CSn,
          SCLK => SCLK,   
          AN0 => AN0,     -- sal
          AN1 => AN1,
          AN2 => AN2,
          AN3 => AN3,
          CA => CA,
          CB => CB,
          CC => CC,
          CD => CD,
          CE => CE,
          CF => CF,
          CG => CG
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 
 RESET <= '1','0' after 1 ns ;
	
	--------------------------------------------------------------
	------------------------------------------------------------
process
variable fase : real ;
begin
fase := 2.0*3.14159*F*t ;
if ( fase > 2.0*MATH_PI ) then fase := fase - 2.0*MATH_PI  ; end if ;
senal <= sin(fase);
t<= t+10.0E-6 ;
wait for 10 us ;
end process;


process
variable fase : real ;
begin
fase := 2.0*3.14159*15000*t ;
if ( fase > 2.0*MATH_PI ) then fase := fase - 2.0*MATH_PI; end if ;
ruido <= sin(fase);
wait for 10 us ;
end process;

ENTRADA_real <= (1.0 +senal )/2.0 * 4095.0 ;  
	
	-- Stimulus process
	process
	variable tmp : std_logic_vector(11 downto 0 ) ;
	begin
		wait until CSn = '0' ;	
		tmp := conv_std_logic_vector(integer(ENTRADA_real),12);
		SDATA<='0';
		wait until SCLK = '0' ;
		wait until SCLK = '0' ;		
		wait until SCLK = '0' ;				
		for j in 11 downto 0 loop	
			wait until SCLK = '0' ;
			SDATA<=tmp(j) ;
		end loop;
  		wait until CSn = '1' ;		
	end process;
	
	

END;
