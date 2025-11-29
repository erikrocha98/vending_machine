-- ============================================
-- Arquivo: comparator_8bit.vhd
-- Descrição: Comparador genérico (A >= B, A = B, A < B)
-- Autores: Erik Avelino e Malu Lauar
-- ============================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity comparator_8bit is
    port (
        tot       : in  std_logic_vector(7 downto 0);
        s         : in  std_logic_vector(7 downto 0);
        tot_gte_s : out std_logic;
        tot_eq_s  : out std_logic;
        tot_lt_s  : out std_logic
    );
end comparator_8bit;

architecture behavioral of comparator_8bit is
begin
    process(tot, s)
    begin
        if unsigned(tot) > unsigned(s) then
            tot_gte_s <= '1'; tot_eq_s <= '0'; tot_lt_s <= '0';
        elsif unsigned(tot) = unsigned(s) then
            tot_gte_s <= '1'; tot_eq_s <= '1'; tot_lt_s <= '0';
        else
            tot_gte_s <= '0'; tot_eq_s <= '0'; tot_lt_s <= '1';
        end if;
    end process;
end behavioral;