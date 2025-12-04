-- ============================================
-- Arquivo: pin_assingment
-- Autores: Erik Avelino e Malu Lauar
-- ============================================

library IEEE;
use IEEE.std_logic_1164.all;

entity hex7seg is
    port (
        bin : in  std_logic_vector(3 downto 0);
        seg : out std_logic_vector(7 downto 0)
    );
end entity hex7seg;

architecture behavioral of hex7seg is
begin
    process(bin)
    begin
        case bin is
            when "0000" => seg <= "11000000"; -- 0
            when "0001" => seg <= "11111001"; -- 1
            when "0010" => seg <= "10100100"; -- 2
            when "0011" => seg <= "10110000"; -- 3
            when "0100" => seg <= "10011001"; -- 4
            when "0101" => seg <= "10010010"; -- 5
            when "0110" => seg <= "10000010"; -- 6
            when "0111" => seg <= "11111000"; -- 7
            when "1000" => seg <= "10000000"; -- 8
            when "1001" => seg <= "10010000"; -- 9
            when others => seg <= "11111111"; 
        end case;
    end process;
end architecture;