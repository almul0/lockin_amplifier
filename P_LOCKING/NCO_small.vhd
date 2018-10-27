----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:47:18 10/29/2014 
-- Design Name: 
-- Module Name:    NCO - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.math_real.all ;
Use std.textio.all;
Use ieee.std_logic_textio.all;

entity NCO is
    Port ( CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           SENO,COSENO : out  STD_LOGIC_VECTOR (15 downto 0);
			  TRIG : in STD_LOGIC);
end NCO;

architecture Behavioral of NCO is
type rom_type is array (4 downto 0) of std_logic_vector(15 downto 0) ;

constant seno_rom : rom_type := (
	conv_std_logic_vector(0,16),
	conv_std_logic_vector(31164,16),
	conv_std_logic_vector(19261,16),
	conv_std_logic_vector(-19261,16),
	conv_std_logic_vector(-31164,16));
	          

constant coseno_rom : rom_type := (
	conv_std_logic_vector(32767,16),
	conv_std_logic_vector(10126,16),
	conv_std_logic_vector(-26510,16),
	conv_std_logic_vector(-26510,16),
	conv_std_logic_vector(10126,16));

-- translate_off
signal seno_sig : STD_LOGIC_VECTOR (15 downto 0) ;
signal coseno_sig : STD_LOGIC_VECTOR (15 downto 0) ;
-- translate_on

-- signal trig : std_logic_vector(0 downto 0) ;

begin

--process(RESET,CLK) 
--variable FM : unsigned(11 downto 0) ; 
--begin
--if( RESET = '1' ) then
--	FM := (OTHERS => '0' ) ;
--	trig <= "0" ;
--elsif( CLK'event AND clk = '1' ) then
--	trig <= "0" ;
--	if ( FM = 500 ) then 
--		FM := (OTHERS => '0' ) ;
--		trig <= "1" ;
--	else FM := FM +1 ;
--	end if ;
--end if;
--end process ;

-- CAMBIAR, CUIDADO EL RESET ES ACTIVO EN 0

process(RESET,CLK) 
variable acc: unsigned(2 downto 0) := (others => '0');
begin
if( RESET = '1' ) then
	seno <= (OTHERS => '0' ) ;
	coseno <= (OTHERS => '0' ) ;
	-- translate_off
	seno_sig <= (OTHERS => '0' ) ;
	coseno_sig <= (OTHERS => '0' ) ;
	-- translate_on
elsif( CLK'event AND clk = '1' ) then
	if (TRIG = '1') then 
		SENO <= seno_rom(conv_integer(acc));
		COSENO <= coseno_rom(conv_integer(acc));
		
		-- translate_off
		seno_sig <= seno_rom(conv_integer(acc));
		coseno_sig <= coseno_rom(conv_integer(acc));
		-- translate_on
		
		IF acc < 4 THEN
			acc := acc+1;
		ELSE 
			acc :=(OTHERS => '0' );		
		END IF;
	end if ;
end if;
end process ;

-- translate_off  para no sintetizar
write_osci:process
file output_seno_file : text ;
file output_coseno_file : text ;
variable my_line : line ;
variable fstatus: FILE_OPEN_STATUS;
begin
file_open(fstatus,output_seno_file,"locking_seno.txt",WRITE_MODE);
if( fstatus /= OPEN_OK) then
 assert false report "error apertura fichero" severity failure ;
end if ;
file_open(fstatus,output_coseno_file,"locking_coseno.txt",WRITE_MODE);
if( fstatus /= OPEN_OK) then
 assert false report "error apertura fichero" severity failure ;
end if ;
wait for 10 us ;
for i in 1 to 512*16 loop 
 wait until trig = '1' ; -- FS
 write(my_line,conv_integer(signed(seno_sig)));
 writeline(output_seno_file,my_line) ;
 write(my_line,conv_integer(signed(coseno_sig)));
 writeline(output_coseno_file,my_line) ;
end loop ;
file_close(output_coseno_file) ;
file_close(output_seno_file) ;
assert false report "fin" severity failure ;

end process ;

-- translate_on


end Behavioral;

