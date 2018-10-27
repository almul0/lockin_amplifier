---------------------------------------------------------------------------------
-- Created by: 
-- Filename   : ctl_adc7476a.vhd
-- Author   : 
-- Created On: 2013-05-20 11:15
-- Last Modified	: 2013-05-22 11:45
-- Version: v1.0
-- Description: 
--				
--				
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ctl_adc7476a is
port(
	    CLK	 : in	std_logic;
	    RESET	 : in	std_logic;
	    SDATA: in	std_logic;
	    CSn	 : out	std_logic;
	    SCLK : out	std_logic;
		 START: in std_logic;
	    DOUT : out	std_logic_vector (11 downto 0)
    );
end ctl_adc7476a;

architecture arc of ctl_adc7476a is


begin
process(CLK, RESET)
variable reg: std_logic_vector(11 downto 0);
type estado_t is (reposo, inicio, sclk0_0, sclk0_1, sclk1_0, sclk1_1, fin);
variable estado : estado_t;
variable cont: std_logic_vector (31 downto 0);
begin
	if (RESET = '1') then	
		CSn <= '1';
		SCLk <= '1';
		DOUT <= (others => '0');
		reg := (others => '0');
		estado := reposo;
		cont := (others => '0');
	elsif (clk'event and clk = '1' ) then 
		case ESTADO is
			when reposo =>
				CSn <= '1';
				SCLK <= '1';
				if START = '1' then
					ESTADO := inicio;
					CSn <= '0';
				end if;
				cont := (others => '0');
			
			when inicio =>
				ESTADO := sclk0_0;
				SCLK <= '0';
				
			when sclk0_0 =>
				ESTADO := sclk0_1;
				
			when sclk0_1 =>
				SCLK <= '1';
				ESTADO := sclk1_0;
				if (cont =  15) then 
					ESTADO := fin;
					DOUT <= reg;
				end if;
				reg := reg(10 downto 0) & SDATA;
			
			when  sclk1_0 =>
				ESTADO := sclk1_1;
				
			when sclk1_1 =>
				SCLK <= '0';
				ESTADO := sclk0_0;
				cont := cont + 1;
				
			when fin =>
				CSn <= '1';
				if ( cont = 49 ) then 
					ESTADO := reposo;
				else cont := cont + 1;
				end if;
		end case;
	end if;		
end process ;


end arc;

