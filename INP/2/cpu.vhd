-- cpu.vhd: Simple 8-bit CPU (BrainF*ck interpreter)
-- Copyright (C) 2018 Brno University of Technology,
--                    Faculty of Information Technology
-- Author(s): xsajdi01
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity cpu is
 port (
   CLK   : in std_logic;  -- hodinovy signal
   RESET : in std_logic;  -- asynchronni reset procesoru
   EN    : in std_logic;  -- povoleni cinnosti procesoru
 
   -- synchronni pamet ROM
   CODE_ADDR : out std_logic_vector(11 downto 0); -- adresa do pameti
   CODE_DATA : in std_logic_vector(7 downto 0);   -- CODE_DATA <- rom[CODE_ADDR] pokud CODE_EN='1'
   CODE_EN   : out std_logic;                     -- povoleni cinnosti
   
   -- synchronni pamet RAM
   DATA_ADDR  : out std_logic_vector(9 downto 0); -- adresa do pameti
   DATA_WDATA : out std_logic_vector(7 downto 0); -- mem[DATA_ADDR] <- DATA_WDATA pokud DATA_EN='1'
   DATA_RDATA : in std_logic_vector(7 downto 0);  -- DATA_RDATA <- ram[DATA_ADDR] pokud DATA_EN='1'
   DATA_RDWR  : out std_logic;                    -- cteni z pameti (DATA_RDWR='1') / zapis do pameti (DATA_RDWR='0')
   DATA_EN    : out std_logic;                    -- povoleni cinnosti
   
   -- vstupni port
   IN_DATA   : in std_logic_vector(7 downto 0);   -- IN_DATA obsahuje stisknuty znak klavesnice pokud IN_VLD='1' a IN_REQ='1'
   IN_VLD    : in std_logic;                      -- data platna pokud IN_VLD='1'
   IN_REQ    : out std_logic;                     -- pozadavek na vstup dat z klavesnice
   
   -- vystupni port
   OUT_DATA : out  std_logic_vector(7 downto 0);  -- zapisovana data
   OUT_BUSY : in std_logic;                       -- pokud OUT_BUSY='1', LCD je zaneprazdnen, nelze zapisovat,  OUT_WE musi byt '0'
   OUT_WE   : out std_logic                       -- LCD <- OUT_DATA pokud OUT_WE='1' a OUT_BUSY='0'
 );
end cpu;


-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of cpu is
-----------------------------INSTRUKCE------------------------------
type t_instruction is (incPt,decPt,incValue,decValue,whileStart,whileEnd,put,get,halt,setValue, comment);
signal instruction: t_instruction;

type t_state is (S_IDLE,S_LOAD,S_STOP,S_INC, S_DEC, S_IN, S_OUT,
					  S_WHILE_START, S_WHILE_START_LOOP, S_WHILE_START_LOOP2,
					  S_WHILE_END, S_WHILE_END_LOOP, S_WHILE_END_LOOP2,
					  S_COMMENT, S_COMMENT2, S_COMMENT_WHILE_END, S_COMMENT_WHILE_END2, 
					  S_COMMENT_WHILE_START, S_COMMENT_WHILE_START2,
					  S_SET_VALUE);
signal actualState : t_state;
signal nextState : t_state;

signal regCnt : std_logic_vector (7 downto 0);
signal incCnt : std_logic;
signal decCnt : std_logic;

signal regPtr : std_logic_vector (9 downto 0);
signal incPtr : std_logic;
signal decPtr : std_logic;

signal regPc : std_logic_vector (11 downto 0);
signal incPc : std_logic;
signal decPc : std_logic;
 -- zde dopiste potrebne deklarace signalu

begin -- behavior

CODE_ADDR <= regPc;
DATA_ADDR <= regPtr;

load_Instruction: process (CODE_DATA)
begin
	case CODE_DATA is
		when X"3E" =>
			instruction <= incPt;
		when X"3C" =>
			instruction <= decPt;
		when X"2B" =>
			instruction <= incValue;
		when X"2D" =>
			instruction <= decValue;
		when X"5B" =>
			instruction <= whileStart;
		when X"5D" =>
			instruction <= whileEnd;
		when X"2E" =>
			instruction <= put;
		when X"2C" =>
			instruction <= get;
		when X"00" =>
			instruction <= halt;
		when X"23" =>
			instruction <= comment;
		when others =>
			instruction <= setValue;
	end case;
end process;

cnt: process (RESET, CLK)
begin
	if (RESET = '1') then
		regCnt <= "00000000";
	elsif (CLK'event and CLK = '1') then
		if (incCnt = '1') then
			regCnt <= regCnt + 1;
		elsif (decCnt = '1') then
			regCnt <= regCnt - 1;
		end if;
	end if;
end process;

ptr: process (RESET, CLK)
begin
	if (RESET = '1') then
		regPtr <= "0000000000";
	elsif (CLK'event and CLK = '1') then
		if (incPtr = '1') then
			regPtr <= regPtr + 1;
		elsif (decPtr = '1') then
			regPtr <= regPtr - 1;
		end if;
	end if;
end process;

pc: process(RESET,CLK)
begin
	if (RESET = '1') then
		regPc <= "000000000000";
	elsif (CLK'event and CLK = '1') then
		if (incPc = '1') then
			regPc <= regPc + 1;
		elsif (decPc = '1') then
			regPc <= regPc - 1;
		end if;
	end if;
end process;


stateUpdate: process(RESET, CLK, EN)
begin
	if (RESET = '1') then
		actualState <= S_IDLE;
	elsif(CLK'event and CLK = '1') then
		if (EN = '1') then
			actualState <= nextState;
		end if;
	end if;
end process;

nextStateUpdate: process (CODE_DATA, DATA_RDATA,EN, IN_DATA,IN_VLD,OUT_BUSY, actualState, instruction, regCnt)
begin
	--not sure here
	CODE_EN <= '0';
	DATA_EN <= '0';
	
	OUT_WE <= '0';
	IN_REQ <= '0';

	incPc <= '0';
	decPc <= '0';
	
	incCnt <= '0';
	decCnt <= '0';
	
	incPtr <= '0';
	decPtr <= '0';
	
	nextState <= S_IDLE;
	
	case actualState is
		when S_IDLE =>
			CODE_EN <= '1';
			nextState <= S_LOAD;
		when S_STOP =>
			nextState <= S_STOP;
			
		when S_COMMENT =>
			if (instruction = comment) then
				CODE_EN <= '1';
				incPc <= '1';
				nextState <= S_IDLE;
			else
				incPc <= '1';
				CODE_EN <= '1';
				nextState <= S_COMMENT2;
			end if;
		when S_COMMENT2 =>
			CODE_EN <= '1';
			nextState <= S_COMMENT;
		
		when S_COMMENT_WHILE_END =>
			if (instruction = comment) then
				decPc <= '1';
				nextState <= S_WHILE_END_LOOP;
			else
				decPc <= '1';
				nextState <= S_COMMENT_WHILE_END2;
			end if;
		when S_COMMENT_WHILE_END2 =>
			CODE_EN <= '1';
			nextState <= S_COMMENT_WHILE_END;
		
		when S_COMMENT_WHILE_START =>
			if (instruction = comment) then
				incPc <= '1';
				nextState <= S_WHILE_START_LOOP;
			else
				incPc <= '1';
				nextState <= S_COMMENT_WHILE_START2;
			end if;
		when S_COMMENT_WHILE_START2 =>
				CODE_EN <= '1';
				nextState <= S_COMMENT_WHILE_START;
			
		when S_LOAD =>
			case instruction is
				when incValue =>
					DATA_EN <= '1';
					DATA_RDWR <= '1';
					nextState <= S_INC;
				when decValue =>
					DATA_EN <= '1';
					DATA_RDWR <= '1';
					nextState <= S_DEC;
				when incPt =>
					incPtr <= '1';
					incPC <= '1';
					nextState <= S_IDLE;
				when decPt =>
					decPtr <= '1';
					incPC <= '1';
					nextState <= S_IDLE;
				when put =>
					DATA_EN <= '1';
					DATA_RDWR <= '1';
					nextState <= S_OUT;
				when get =>
					IN_REQ <= '1';
					nextState <= S_IN;
				when halt =>
					nextState <= S_STOP;
				when whileStart =>
					DATA_EN <= '1';
					DATA_RDWR <= '1';
					nextState <= S_WHILE_START;
				when whileEnd =>
					DATA_EN <= '1';
					DATA_RDWR <= '1';
					nextState <= S_WHILE_END;
				when comment =>
					incPc <= '1';
					CODE_EN <= '1';
					nextState <= S_COMMENT2;
				when others =>
					DATA_EN <= '1';
					CODE_EN <= '1';
					DATA_RDWR <= '1';
					nextState <= S_SET_VALUE;
			end case;
		
		when S_SET_VALUE =>
			case CODE_DATA is 
				when X"30" =>
					DATA_WDATA <= X"00";
				when X"31" =>
					DATA_WDATA <= X"10";
				when X"32" =>
					DATA_WDATA <= X"20";
				when X"33" =>
					DATA_WDATA <= X"30";
				when X"34" =>
					DATA_WDATA <= X"40";
				when X"35" =>
					DATA_WDATA <= X"50";
				when X"36" =>
					DATA_WDATA <= X"60";
				when X"37" =>
					DATA_WDATA <= X"70";
				when X"38" =>
					DATA_WDATA <= X"80";
				when X"39" =>
					DATA_WDATA <= X"90";
				when X"41" =>
					DATA_WDATA <= X"A0";
				when X"42" =>
					DATA_WDATA <= X"B0";
				when X"43" =>
					DATA_WDATA <= X"C0";
				when X"44" =>
					DATA_WDATA <= X"D0";
				when X"45" =>
					DATA_WDATA <= X"E0";
				when X"46" =>
					DATA_WDATA <= X"F0";
				when others =>
				
			end case;
			DATA_RDWR <= '0';
			DATA_EN <= '1';
			incPc <= '1';
			nextState <= S_IDLE;
			
		when S_INC =>
			DATA_WDATA <= DATA_RDATA + 1;
			DATA_RDWR <= '0';
			DATA_EN <= '1';
			incPc <= '1';
			nextState <= S_IDLE;
			
		when S_DEC =>
			DATA_WDATA <= DATA_RDATA - 1;
			DATA_RDWR <= '0';
			DATA_EN <= '1';
			incPc <= '1';
			nextState <= S_IDLE;
		when S_OUT =>
			if (OUT_BUSY = '0') then
				OUT_DATA <= DATA_RDATA;
				OUT_WE <= '1';
				incPc <= '1';
				nextState <= S_IDLE;
			else
				nextState <= S_OUT;
			end if;
			
		when S_IN =>
			if (IN_VLD = '1') then
				DATA_RDWR <= '0';
				DATA_WDATA <= IN_DATA;
				DATA_EN <= '1';
				incPc <= '1';
				nextState <= S_IDLE;
			else
				IN_REQ <= '1';
				nextState <= S_IN;
			end if;
			
		when S_WHILE_START =>
			if (DATA_RDATA = 0) then
				incCnt <= '1';
				incPc <= '1';
				nextState <= S_WHILE_START_LOOP;
			else
				incPc <= '1';
				nextState <= S_IDLE;
			end if;
			
		when S_WHILE_START_LOOP =>
			CODE_EN <= '1';
			nextState <= S_WHILE_START_LOOP2;
			
		when S_WHILE_START_LOOP2 =>
			if (regCnt = 0) then
				nextState <= S_IDLE;
			elsif (instruction = comment) then
				incPc <= '1';
				CODE_EN <= '1';
				nextState <= S_COMMENT_WHILE_START2;
			elsif (instruction = whileEnd) then
				incPc <= '1';
				decCnt <= '1';
				nextState <= S_WHILE_START_LOOP;
			elsif (instruction = whileStart) then
				incPc <='1';
				incCnt <='1';
				nextState <= S_WHILE_START_LOOP;
			else
				incPC <='1';
				nextState <= S_WHILE_START_LOOP;
			end if;
			
		when S_WHILE_END =>
			if(DATA_RDATA = 0) then
				incPc <= '1';
				nextState <= S_IDLE;
			else
				decPc <= '1';
				incCnt <= '1';
				nextState <= S_WHILE_END_LOOP;
			end if;
			
		when S_WHILE_END_LOOP =>
			CODE_EN <= '1';
			nextState <= S_WHILE_END_LOOP2;
			
		when S_WHILE_END_LOOP2 =>
			if(regCnt = 0) then
				incPc <= '1';
				nextState <= S_IDLE;
			elsif (instruction = comment) then
				decPc <= '1';
				CODE_EN <= '1';
				nextState <= S_COMMENT_WHILE_END2;
			elsif (instruction = whileEnd) then
				incCnt <= '1';
				decPc <= '1';
				nextState <= S_WHILE_END_LOOP;
			elsif (instruction = whileStart) then
				decCnt <= '1';
				decPc <= '1';
				nextState <= S_WHILE_END_LOOP;
			else
				decPc <= '1';
				nextState <= S_WHILE_END_LOOP;
			end if;
	end case;
	
end process;




 -- zde dopiste vlastni VHDL kod dle blokoveho schema

 -- inspirujte se kodem procesoru ze cviceni

end behavioral;
 
