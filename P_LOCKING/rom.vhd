
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.math_real.all ;


entity rom is
    Port ( ADDR : in  STD_LOGIC_VECTOR (11 downto 0);
				CLK : in std_logic ;
				RESET : in std_logic ;
           Y : out  STD_LOGIC_VECTOR (15 downto 0));
end rom;

architecture Behavioral of rom is

type rom_type is array (2**12-1 downto 0) of std_logic_vector(15 downto 0) ;

function tabla_adc return rom_type is
variable rom : rom_type ;
variable bcd : std_logic_vector(3 downto 0) ;
variable ri,digit: integer ;
begin
for i in 0 to 2**12-1 loop
	ri:= integer((3.3*1000.0)/2.0*sqrt(4.0*real(i)/2.0**12));
	digit := ri/1000 ;
	bcd := conv_std_logic_vector(digit,4) ;
	rom(i)(15 downto 12) := bcd ;
	
	ri := ri-1000*digit ;
	
	digit := ri/100 ;
	bcd := conv_std_logic_vector(digit,4) ;
	rom(i)(11 downto 8) := bcd ;
	ri := ri-100*digit ;

  digit := ri/10 ;
	bcd := conv_std_logic_vector(digit,4) ;
	rom(i)(7 downto 4) := bcd ;
	ri := ri-10*digit ;

	bcd := conv_std_logic_vector(ri,4) ;
	rom(i)(3 downto 0) := bcd ;

			
end loop ;
return rom ;

end tabla_adc ;

constant adc : rom_type := tabla_adc ;

begin


process(CLK)
begin
if (clk'event and clk = '1' ) then 
	y <= adc(conv_integer(unsigned(ADDR)));
end if ;
end process ;


end Behavioral;

