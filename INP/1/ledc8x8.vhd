library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
port (
    RESET : IN std_logic;
    SMCLK : IN std_logic;
    ROW : OUT std_logic_vector(0 to 7);
    LED : OUT std_logic_vector(7 downto 0)
);
end ledc8x8;

architecture main of ledc8x8 is
    signal LEDS : std_logic_vector(7 downto 0) := (others => '0'); --vnutorne signaly
    signal ROWS : std_logic_vector(7 downto 0) := (others => '0');
    signal cnt: std_logic_vector(11 downto 0)  := (others => '0');
    signal cnt2: std_logic_vector(20 downto 0)  := (others => '0');
    signal ce: std_logic;
    signal state : std_logic_vector(1 downto 0) := "00";
    
begin

    generator_ce: process(SMCLK, RESET) -- 
    begin
		if RESET = '1' then 
			cnt <= (others => '0');
        elsif SMCLK'event and SMCLK = '1' then -- nástupná hrana
            cnt <= cnt + 1;
        end if;
    end process generator_ce;

    ce <= '1' when cnt = X"FF" else '0';
    
    state_changer: process(SMCLK) 
    begin
        if RESET = '1' then 
			cnt2 <= (others => '0');
        elsif SMCLK'event and SMCLK = '1' then -- nástupná hrana
            cnt2 <= cnt2 + 1;
            if (cnt2 = "111000010000000000000") then
                state <= state + 1;
                cnt2 <= (others => '0');
            end if;
        end if;
    end process state_changer;

    rotation: process(RESET, cnt, SMCLK)
	begin	
		if RESET = '1' then --asynchrony reset
			ROWS <= "10000000"; 
		elsif SMCLK'event and SMCLK = '1' and ce = '1' then
			ROWS <= ROWS(0) & ROWS(7 downto 1); --konkatenacia na posunutie jednotky
		end if;
	end process rotation;

    decoder: process(ROWS)
	begin
		case ROWS is
            if state = "00" then -- nic
                when "10000000" => LEDS <= "00000001";
                when "01000000" => LEDS <= "11101111";
                when "00100000" => LEDS <= "11101111";
                when "00010000" => LEDS <= "11101111";
                when "00001000" => LEDS <= "11101111";
                when "00000100" => LEDS <= "11101111";
                when "00000010" => LEDS <= "11101111";
                when "00000001" => LEDS <= "11101111";
                when others =>     LEDS <= "11111111";
            elsif state = "01" then -- H
                when "10000000" => LEDS <= "11111111";
                when "01000000" => LEDS <= "11111111";
                when "00100000" => LEDS <= "11111111";
                when "00010000" => LEDS <= "11111111";
                when "00001000" => LEDS <= "11111111";
                when "00000100" => LEDS <= "11111111";
                when "00000010" => LEDS <= "11111111";
                when "00000001" => LEDS <= "11111111";
                when others =>     LEDS <= "11111111";
             elsif state = "10" then  -- nic
                when "10000000" => LEDS <= "01111110";
                when "01000000" => LEDS <= "01111110";
                when "00100000" => LEDS <= "01111110";
                when "00010000" => LEDS <= "00000000";
                when "00001000" => LEDS <= "01111110";
                when "00000100" => LEDS <= "01111110";
                when "00000010" => LEDS <= "01111110";
                when "00000001" => LEDS <= "11111111";
                when others =>     LEDS <= "11111111";
            elsif state = "11" then -- T
                when "10000000" => LEDS <= "11111111";
                when "01000000" => LEDS <= "11111111";
                when "00100000" => LEDS <= "11111111";
                when "00010000" => LEDS <= "11111111";
                when "00001000" => LEDS <= "11111111";
                when "00000100" => LEDS <= "11111111";
                when "00000010" => LEDS <= "11111111";
                when "00000001" => LEDS <= "11111111";
                when others =>     LEDS <= "11111111";
            end if;
		end case;
	end process decoder;

    ROW <= ROWS;
	LED <= LEDS;

end main;
