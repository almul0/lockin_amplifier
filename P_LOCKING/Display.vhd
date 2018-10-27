
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;



entity Display is
    Port ( CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC; 
           BCD : in STD_LOGIC_VECTOR(15 downto 0 ); 
           AN0 : out  STD_LOGIC;  -- U
           AN1 : out  STD_LOGIC;  -- D
           AN2 : out  STD_LOGIC;  -- C
           AN3 : out  STD_LOGIC;  -- M
           CA : out  STD_LOGIC;
           CB : out  STD_LOGIC;
           CC : out  STD_LOGIC;
           CD : out  STD_LOGIC;
           CE : out  STD_LOGIC;
           CF : out  STD_LOGIC;
           CG : out  STD_LOGIC);
end Display;



architecture Behavioral of Display is

signal AN : std_logic_vector (3 downto 0) ;
signal AN_SIG : std_logic_vector (3 downto 0) ;
signal CNT1K : unsigned (16 downto 0);
signal CNT1K_SIG : unsigned(16	 downto 0);

begin

process(CLK, RESET)
begin
	if (RESET = '1') then
		AN <= "1110";
		CNT1K <= (others => '0');
	elsif (clk'event and clk = '1' ) then
		CNT1K <= CNT1K_SIG;
		AN <= AN_SIG;
	end if;
end process;

AN0 <= AN(0);
AN1 <= AN(1); 
AN2 <= AN(2); 
AN3 <= AN(3); 

AN_SIG <= (AN(2 downto 0) & AN(3)) WHEN (CNT1K = 49999) ELSE AN;
CNT1K_SIG <= (others => '0') WHEN (CNT1K = 49999) ELSE CNT1K + 1;

process(BCD,AN)
variable tmp :std_logic_vector(3 downto 0) ;
begin

-- ASIGNAR tmp con lo que se quiera visualizar

case AN is
	when "0111" => 
		tmp := BCD(15 downto 12);
	when "1011" => 
		tmp := BCD(11 downto 8);
	when "1101" => 
		tmp := BCD(7 downto 4);
	when "1110" => 
		tmp := BCD(3 downto 0);
	when others => 
		tmp := BCD(15 downto 12);
end case;

CA <= '1' ; CB <= '1' ;CC <= '1' ;CD <= '1' ;CE <= '1' ;CF <= '1' ;CG <= '1' ;

case tmp is
	when "0001" => CB <= '0' ;CC <= '0' ;
	when "0010" => CA <= '0' ;CB <= '0' ;CG <= '0' ;CE <= '0' ;CD <= '0' ;
	when "0011" => CA <= '0' ;CB <= '0' ;CG <= '0' ;CC <= '0' ;CD <= '0' ;
	when "0100" => CB <= '0' ;CC <= '0' ;CG <= '0' ;CF <= '0' ;
	when "0101" => CA <= '0' ;CF <= '0' ;CG <= '0' ;CC <= '0' ;CD <= '0' ;
	when "0110" => CA <= '0' ;CF <= '0' ;CG <= '0' ;CC <= '0' ;CD <= '0' ;CE <= '0' ;
	when "0111" => CB <= '0' ;CC <= '0' ;CA <= '0' ;
	when "1000" => CA <= '0' ;CF <= '0' ;CG <= '0' ;CC <= '0' ;CD <= '0' ;CE <= '0' ;CB <= '0' ;
	when "1001" => CA <= '0' ;CF <= '0' ;CG <= '0' ;CC <= '0' ;CD <= '0' ;CB <= '0' ;
	when "0000" => CA <= '0' ;CF <= '0' ;CC <= '0' ;CD <= '0' ;CE <= '0' ;CB <= '0' ;
	when others => null ;
end case ;
end process ;


end Behavioral;











