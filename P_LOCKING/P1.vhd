----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:00:03 10/03/2013 
-- Design Name: 
-- Module Name:    P1 - Behavioral 
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

entity P1 is
    Port ( CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;  
				SDATA : In STD_LOGIC;
				CSn : out  STD_LOGIC;
				SCLK : out  STD_LOGIC;
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
end P1;

architecture Behavioral of P1 is

signal BCD : std_logic_vector(15 downto 0) ;
signal VADC : std_logic_vector(11 downto 0) ;
signal START: std_logic ;
signal FILTRO_START, FILTRO_START_SIG: std_logic := '0';
signal FILTRO_FIN, FILTRO_FIN_SIG: std_logic := '0';

signal seno_lv,coseno_lv : std_logic_vector(15 downto 0);

signal I_LV,Q_LV : std_logic_vector(28 downto 0) := (OTHERS => '0' );
signal I_LV_SIG, Q_LV_SIG: std_logic_vector(28 downto 0) := (OTHERS => '0' );

SIGNAL I_X1, I_X2: std_logic_vector(28 downto 0) := (OTHERS => '0' );
SIGNAL I_X1_SIG, I_X2_SIG : std_logic_vector(28 downto 0) := (OTHERS => '0' );
SIGNAL I_Y1, I_Y2 : std_logic_vector(28 downto 0) := (OTHERS => '0' );
SIGNAL I_Y1_SIG, I_Y2_SIG : std_logic_vector(28 downto 0) := (OTHERS => '0' );

SIGNAL Q_X1, Q_X2: std_logic_vector(28 downto 0) := (OTHERS => '0' );
SIGNAL Q_X1_SIG, Q_X2_SIG : std_logic_vector(28 downto 0) := (OTHERS => '0' );
SIGNAL Q_Y1, Q_Y2 : std_logic_vector(28 downto 0) := (OTHERS => '0' );
SIGNAL Q_Y1_SIG, Q_Y2_SIG : std_logic_vector(28 downto 0) := (OTHERS => '0' );

SIGNAL I2, Q2 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL I2_SIG, Q2_SIG: std_logic_vector(31 downto 0) := (others => '0');

SIGNAL FILTRO_X, FILTRO_X1, FILTRO_X2 : std_logic_vector(28 downto 0) := (OTHERS => '0' );
SIGNAL FILTRO_X_SIG, FILTRO_X1_SIG, FILTRO_X2_SIG : std_logic_vector(28 downto 0) := (OTHERS => '0' );
SIGNAL FILTRO_OUT, FILTRO_Y1, FILTRO_Y2 : std_logic_vector(28 downto 0) := (OTHERS => '0' );
SIGNAL FILTRO_OUT_SIG, FILTRO_Y1_SIG, FILTRO_Y2_SIG : std_logic_vector(28 downto 0) := (OTHERS => '0' );

SIGNAL FILTRO_Y1_TMP, FILTRO_Y2_TMP : std_logic_vector(44 downto 0) := (others => '0');
SIGNAL FILTRO_Y1_TMP_SIG, FILTRO_Y2_TMP_SIG: std_logic_vector(44 downto 0) := (others => '0');
signal MULT_Y: std_logic_vector(44 downto 0) := (others => '0') ;
signal MULT_Y_Y: std_logic_vector(28 downto 0) := (OTHERS => '0' );
signal MULT_Y_COEF:  std_logic_vector(15 downto 0) := (OTHERS => '0' );
signal ABS_CUAD:  std_logic_vector(31 downto 0) := (others => '0');
signal ABS_CUAD_FAC: std_logic_vector(15 downto 0) := (OTHERS => '0' );
SIGNAL FILTRO_OUT_TMP, FILTRO_OUT_TMP_SIG : std_logic_vector(46 downto 0) := (others => '0');

signal SUMA: std_logic_vector(11 downto 0) := (OTHERS => '0' );
signal SUMA_SIG: std_logic_vector(11 downto 0) := (OTHERS => '0' );

constant A1: std_logic_vector(15 downto 0) := conv_std_logic_vector(31313,16);
constant A2: std_logic_vector(15 downto 0) := conv_std_logic_vector(29982,16);
constant GAIN: std_logic_vector(15 downto 0) := conv_std_logic_vector(31699,16);

TYPE LOCKIN IS (REPOSO, EMPEZAR, FASE, FILTRO_FASE, CUADRATURA, FILTRO_CUADRATURA, CUADRADO_FASE, CUADRADO_CUADRATURA, SUMA_RAMAS);
SIGNAL LOCKIN_ESTADO, LOCKIN_ESTADO_SIG: LOCKIN;

TYPE FILTRO_IIR IS (REPOSO, FIR_S1, FIR_S2, FIR_G, IIR_A1, IIR_A2, IIR_S1, IIR_S2);
SIGNAL FILTRO_IIR_ESTADO, FILTRO_IIR_ESTADO_SIG: FILTRO_IIR;

-- translate_off
constant F : real := 20000.0 ;
constant A1_real : real:= 1.9111970674260732 ;
constant A2_real:real :=  0.91497583480143374 ;
constant GAIN_real : real :=  0.00094469184384015075 ;

signal ENTRADA_real : real := 0.0 ;
Signal senal,t,ruido : real := 0.0 ;
signal y1_to_real : real := 0.0 ;
signal seno,coseno : real := 0.0 ;
signal I,Q : real := 0.0 ;
signal I_FILTRO_real,Q_FILTRO_real : real := 0.0 ;
signal SUMA_real : real := 0.0 ;
signal SUMA_lv_real : real := 0.0 ;
signal I_lv_r,Q_lv_r : real := 0.0 ;
signal I_FILTRO_lv_r,Q_FILTRO_lv_r : real := 0.0 ;
-- translate_on
begin

I_LV_SIG <= seno_lv * ('0'&VADC) ;
Q_LV_SIG <= coseno_lv * ('0'&VADC) ;

process(RESET,CLK) 
variable FM : unsigned(8 downto 0) ;
begin
if( RESET = '1' ) then
	FM := (OTHERS => '0' ) ;
	START <= '0' ;
	SUMA <= (others => '0');
	LOCKIN_ESTADO <= REPOSO;
	FILTRO_START <= '0';
	FILTRO_FIN <= '0';
	FILTRO_IIR_ESTADO <= REPOSO;
elsif( CLK'event AND clk = '1' ) then
	
	FILTRO_START <= FILTRO_START_SIG;
	FILTRO_FIN <= FILTRO_FIN_SIG;
	
	LOCKIN_ESTADO <= LOCKIN_ESTADO_SIG;
	FILTRO_IIR_ESTADO <= FILTRO_IIR_ESTADO_SIG;
	
	FILTRO_X <= FILTRO_X_SIG;
	FILTRO_X1 <= FILTRO_X1_SIG;
	FILTRO_X2 <= FILTRO_X2_SIG;
	FILTRO_Y1 <= FILTRO_Y1_SIG;
	FILTRO_Y2 <= FILTRO_Y2_SIG;
		
	FILTRO_OUT_TMP <= FILTRO_OUT_TMP_SIG;
	FILTRO_Y1_TMP <= FILTRO_Y1_TMP_SIG;
	FILTRO_Y2_TMP <= FILTRO_Y2_TMP_SIG;
	
	FILTRO_OUT <= FILTRO_OUT_SIG;
	
	I_X2 <= I_X2_SIG;
	I_X1 <= I_X1_SIG;
	I_Y2 <= I_Y2_SIG;
	I_Y1 <= I_Y1_SIG;
	
	Q_X2 <= Q_X2_SIG;
	Q_X1 <= Q_X1_SIG;
	Q_Y2 <= Q_Y2_SIG;
	Q_Y1 <= Q_Y1_SIG;
	
	I2 <= I2_SIG;
	Q2 <= Q2_SIG;
	
	SUMA <= SUMA_SIG;

	START <= '0' ;
	if ( FM = 499 ) then 
		FM := (OTHERS => '0' ) ;
		START <= '1' ;
		I_LV <= I_LV_SIG;
		Q_LV <= Q_LV_SIG;		
	else FM := FM +1 ;
	end if ;
END IF;
END PROCESS;

PROCESS(LOCKIN_ESTADO, START, FILTRO_FIN, I_LV, I_X1, I_X2, I_Y1, I_Y2,
		  FILTRO_OUT, Q_LV, Q_X1, Q_X2,Q_Y1, Q_Y2, I2, Q2, SUMA, 
		  FILTRO_X, FILTRO_X1, FILTRO_X2, FILTRO_Y1, FILTRO_Y2, ABS_CUAD)
variable i2q2 : std_logic_vector(31 downto 0) := (others => '0');
BEGIN
	FILTRO_START_SIG <= '0';
	LOCKIN_ESTADO_SIG <= LOCKIN_ESTADO;
	
	I_X2_SIG <= I_X2;
	I_X1_SIG <= I_X1;
	I_Y2_SIG <= I_Y2;
	I_Y1_SIG <= I_Y1;
	Q_X2_SIG <= Q_X2;
	Q_X1_SIG <= Q_X1;
	Q_Y2_SIG <= Q_Y2;
	Q_Y1_SIG <= Q_Y1;
	
	FILTRO_X_SIG  <= FILTRO_X;
	FILTRO_X1_SIG <= FILTRO_X1;
	FILTRO_X2_SIG <= FILTRO_X2;
	FILTRO_Y1_SIG <= FILTRO_Y1;
	FILTRO_Y2_SIG <= FILTRO_Y2;
	
	I2_SIG <= I2;
	Q2_SIG <= Q2;
	
	ABS_CUAD_FAC <= (others => '0');
	
	SUMA_SIG <= SUMA;
	
	CASE (LOCKIN_ESTADO) IS
		WHEN REPOSO =>
			if START ='1' THEN
				LOCKIN_ESTADO_SIG <= FASE;
			ELSE 
				LOCKIN_ESTADO_SIG <= REPOSO;
			END IF;
			
		WHEN FASE =>
			FILTRO_X_SIG  <= I_LV;
			FILTRO_X1_SIG <= I_X1;
			FILTRO_X2_SIG <= I_X2;
			FILTRO_Y1_SIG <= I_Y1;
			FILTRO_Y2_SIG <= I_Y2;	
			FILTRO_START_SIG <= '1';
			LOCKIN_ESTADO_SIG <= FILTRO_FASE;
		
		WHEN FILTRO_FASE =>
			IF FILTRO_FIN = '1' THEN
				-- translate_off
				I_FILTRO_lv_r <= real(integer(conv_integer(FILTRO_OUT))) * 3.3 * 2.0**(-27 ) ;
				-- translate_on
				I_X2_SIG <= I_X1;
				I_X1_SIG <= I_LV;
				I_Y2_SIG <= I_Y1;
				I_Y1_SIG <= FILTRO_OUT;
				LOCKIN_ESTADO_SIG <= CUADRADO_FASE;			
			END IF;
			
		WHEN CUADRADO_FASE =>
			--I2_SIG <= I_Y1(I_Y1'left-1 downto I_Y1'length-16-1) * I_Y1(I_Y1'left-1 downto I_Y1'length-16-1); -- *<32,30>
			ABS_CUAD_FAC <= I_Y1(I_Y1'left-1 downto I_Y1'length-16-1);
			I2_SIG <= ABS_CUAD;
			LOCKIN_ESTADO_SIG <= CUADRATURA;
		
		WHEN CUADRATURA =>
			FILTRO_X_SIG  <= Q_LV;
			FILTRO_X1_SIG <= Q_X1;
			FILTRO_X2_SIG <= Q_X2;
			FILTRO_Y1_SIG <= Q_Y1;
			FILTRO_Y2_SIG <= Q_Y2;
			FILTRO_START_SIG <= '1';
			LOCKIN_ESTADO_SIG <= FILTRO_CUADRATURA;
			
		WHEN FILTRO_CUADRATURA =>
			IF FILTRO_FIN = '1' THEN
				-- translate_off
				Q_FILTRO_lv_r <= real(integer(conv_integer(FILTRO_OUT))) * 3.3 * 2.0**(-27 ) ;
				-- translate_on
				Q_X2_SIG <= Q_X1;
				Q_X1_SIG <= Q_LV;
				Q_Y2_SIG <= Q_Y1;
				Q_Y1_SIG <= FILTRO_OUT;
				LOCKIN_ESTADO_SIG <= CUADRADO_CUADRATURA;
			END IF;
			
		WHEN CUADRADO_CUADRATURA =>
			ABS_CUAD_FAC <= Q_Y1(Q_Y1'left-1 downto Q_Y1'length-16-1);
			--Q2_SIG <=  Q_Y1(Q_Y1'left-1 downto Q_Y1'length-16-1) * Q_Y1(Q_Y1'left-1 downto Q_Y1'length-16-1); -- *<32,30>
			Q2_SIG <= ABS_CUAD;
			LOCKIN_ESTADO_SIG <= SUMA_RAMAS;
	
		WHEN SUMA_RAMAS =>
			i2q2 := I2 + Q2; -- <32,30>
			i2q2 := i2q2(i2q2'left-2 downto 0) & "00";
			-- translate off
			SUMA_lv_real <= sqrt(real(integer(conv_integer(i2q2(i2q2'left-2 downto i2q2'length-SUMA'length-2)))) * (3.3**2.0) * 2.0**(-12)); -- <32,30>
			-- translate on
			SUMA_SIG <= i2q2(i2q2'left-2 downto i2q2'length-SUMA'length-2); -- Quitamos 20bits, 1 de signo, 1 de parte entera y 18 de precision <12,12>
			LOCKIN_ESTADO_SIG <= REPOSO;
			
		WHEN OTHERS =>
			LOCKIN_ESTADO_SIG <= REPOSO;
	END CASE;
END PROCESS;


PROCESS(FILTRO_IIR_ESTADO, FILTRO_START, FILTRO_OUT_TMP, 
		  FILTRO_Y1_TMP, FILTRO_Y2_TMP, FILTRO_X1, FILTRO_X2, 
		  FILTRO_X, FILTRO_Y1, FILTRO_Y2, FILTRO_OUT, MULT_Y, 
		  MULT_Y_Y, MULT_Y_COEF, ABS_CUAD_FAC)
--variable y1_tmp, y2_tmp: std_logic_vector(44 downto 0) := (others => '0') ;
variable out_tmp: std_logic_vector(46 downto 0) := (others => '0') ;
BEGIN

FILTRO_IIR_ESTADO_SIG <= FILTRO_IIR_ESTADO;

FILTRO_Y1_TMP_SIG <= FILTRO_Y1_TMP;
FILTRO_Y2_TMP_SIG <= FILTRO_Y2_TMP;
FILTRO_OUT_TMP_SIG <= FILTRO_OUT_TMP;
FILTRO_OUT_SIG <= FILTRO_OUT;

MULT_Y_COEF <= A1;
MULT_Y_Y <= FILTRO_Y1;

out_tmp := FILTRO_OUT_TMP;
--y1_tmp := FILTRO_Y1_TMP;
--y2_tmp := FILTRO_Y2_TMP;

FILTRO_FIN_SIG <= '0';

CASE (FILTRO_IIR_ESTADO) IS
	WHEN REPOSO =>
		IF FILTRO_START = '1' THEN
			FILTRO_FIN_SIG <= '0';
			--FILTRO_START_SIG <= '0';
			FILTRO_IIR_ESTADO_SIG <= FIR_S1;
		END IF;
		
	WHEN FIR_S1 =>
		-- FILTRO_X1(27 downto 0) & '0'; -- *2 = <<1 <29,27>
	
		out_tmp := ((out_tmp'left downto FILTRO_X1'length => FILTRO_X1(FILTRO_X1'left)) & (FILTRO_X1(27 downto 0) & '0')) 
					+ ((out_tmp'left downto FILTRO_X2'length =>FILTRO_X2(FILTRO_X2'left)) & FILTRO_X2); -- <30,27>
		
		FILTRO_IIR_ESTADO_SIG <= FIR_S2;
		
	WHEN FIR_S2 =>
		out_tmp := out_tmp + ((out_tmp'left downto FILTRO_X'length => FILTRO_X(FILTRO_X'left)) & FILTRO_X); -- <31,27>
		
		FILTRO_IIR_ESTADO_SIG <= FIR_G;
		
	WHEN FIR_G =>
		out_tmp := out_tmp(30 downto 0) * GAIN; -- <47,52>
		out_tmp := (out_tmp'left downto out_tmp'length-10 => out_tmp(out_tmp'left)) 
				  & out_tmp(out_tmp'left downto 10); -- >>10 <37,42>
		FILTRO_IIR_ESTADO_SIG <= IIR_A1;
		
	WHEN IIR_A1 =>
		-- y1_tmp := MULT_Y_Y; -- *<45,41>
		--y1_tmp := y1_tmp(y1_tmp'left-1 downto 0) & '0'; -- <<1 -> <45,42>
		FILTRO_Y1_TMP_SIG <= MULT_Y(MULT_Y'left-1 downto 0) & '0';
		FILTRO_IIR_ESTADO_SIG <= IIR_A2;
		

	WHEN IIR_A2 =>
		MULT_Y_COEF <= A2;
		MULT_Y_Y <= FILTRO_Y2;
		--y2_tmp := FILTRO_Y2 * A2; -- *<45,42>
		FILTRO_Y2_TMP_SIG <= MULT_Y;
		FILTRO_IIR_ESTADO_SIG <= IIR_S1;
	
	WHEN IIR_S1 =>
		-- SALIDA DE FIR_G + PRIMERA RAMA IIR
		out_tmp := out_tmp + ((out_tmp'left downto FILTRO_Y1_TMP'length => FILTRO_Y1_TMP(FILTRO_Y1_TMP'left)) & FILTRO_Y1_TMP); -- <46,42>
		FILTRO_IIR_ESTADO_SIG <= IIR_S2;
		
	WHEN IIR_S2 =>
		out_tmp := out_tmp  - ((out_tmp'left downto FILTRO_Y2_TMP'length => FILTRO_Y2_TMP(FILTRO_Y2_TMP'left)) & FILTRO_Y2_TMP); -- <47,42>;
		out_tmp := (out_tmp'left downto out_tmp'length-15 => out_tmp(out_tmp'left)) & out_tmp(out_tmp'left downto 15); -- >> 15 <32,27>
		FILTRO_OUT_SIG <= out_tmp(FILTRO_OUT'left downto 0); -- <29,27>		
		FILTRO_IIR_ESTADO_SIG <= REPOSO;
		FILTRO_FIN_SIG <= '1';
		
	WHEN OTHERS =>
		FILTRO_IIR_ESTADO_SIG <= REPOSO;
END CASE;

FILTRO_OUT_TMP_SIG <= out_tmp;

MULT_Y <= MULT_Y_Y * MULT_Y_COEF;
ABS_CUAD <= ABS_CUAD_FAC * ABS_CUAD_FAC;


END PROCESS;


 nco: ENTITY work.nco PORT MAP (
          CLK => CLK,
          RESET => RESET,
          SENO => seno_lv,
			 COSENO => coseno_lv,
			 TRIG => START
        );

ctl_adc7476a: ENTITY work.ctl_adc7476a
	               PORT MAP (  CLK => CLK,
	                           RESET => RESET,
	                           SDATA => SDATA,
	                           CSn => CSn,
	                           SCLK => SCLK,
										START => START,
                             DOUT => VADC); 

									  
  rom: ENTITY work.rom
       PORT MAP ( ADDR => SUMA,
                  CLK => CLK,
                  RESET => RESET,
                  Y =>BCD);
						
  Display: ENTITY work.display
      PORT MAP (CLK => CLK,
                RESET => RESET,
                AN0 => AN0,
                AN1 => AN1,
                AN2 => AN2,
                AN3 => AN3,
					 BCD => BCD,
                CA => CA,
                CB => CB,
                CC => CC,
                CD => CD,
                CE => CE,
                CF => CF,
                CG => CG);

-- translate_off

------------------------------------------------------------

SUMA_real <= sqrt(4.0*(I_FILTRO_real*I_FILTRO_real+Q_FILTRO_real*Q_FILTRO_real));

ENTRADA_real <= real(conv_integer(unsigned(VADC)))*3.3 / 4096.0 ;
I <= ENTRADA_real * real(conv_integer(signed(seno_lv))) / 2.0**15 ;
Q <= ENTRADA_real * real(conv_integer(signed(coseno_lv))) / 2.0**15 ;

I_lv_r <= real(integer(conv_integer(I_lv))) *3.3* 2.0**(-27) ; 
Q_lv_r <= real(integer(conv_integer(Q_lv))) *3.3*2.0**(-27) ;


--------------------------------------------------------------
process
variable x0,x1,x2,y0,y1,y2 : real := 0.0 ;
begin

	x0:= I ;
	y0 := (x0 + 2.0* x1+x2)* GAIN_REAL + A1_real * y1-A2_real *y2 ;  

	y2:= y1 ;
	y1:= y0 ;
	x2:=x1;
	x1:=x0 ;
	I_FILTRO_real <= y0 ;

wait for 10 us ;
end process ;
--------------------------------------------------------------
process
variable x0,x1,x2,y0,y1,y2 : real := 0.0 ;
begin
x0:= Q ;
y0 := (x0 + 2.0* x1+x2)* GAIN_REAL + A1_real * y1-A2_real *y2 ;  
y2:= y1 ;
y1:= y0 ;
x2:=x1;
x1:=x0 ;
Q_FILTRO_real <= y0 ;
wait for 10 us ;
end process ;
-------------------------------------------------------------- 

-- translate_on
					 
end Behavioral;

