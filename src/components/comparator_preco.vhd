-- ============================================
-- Projeto : Máquina de Vendas
-- Arquivo : comparator_preco.vhd
-- Autores : Erik Avelino e Malu Lauar
-- Descrição:
--   Wrapper para o comparador estrutural de 8 bits.
--   Reutiliza o componente comparator_8bit.
--   Saídas:
--      tot_gte_s = '1' se tot >= s
--      tot_eq_s  = '1' se tot  = s
--      tot_lt_s  = '1' se tot < s
-- ============================================

library IEEE;
use IEEE.std_logic_1164.all;

entity comparator_preco is
    port (
        tot       : in  std_logic_vector(7 downto 0);
        s         : in  std_logic_vector(7 downto 0);
        tot_gte_s : out std_logic;
        tot_eq_s  : out std_logic;
        tot_lt_s  : out std_logic
    );
end comparator_preco;

architecture structural of comparator_preco is

    component comparator_8bit
        port (
            tot       : in  std_logic_vector(7 downto 0);
            s         : in  std_logic_vector(7 downto 0);
            tot_gte_s : out std_logic;
            tot_eq_s  : out std_logic;
            tot_lt_s  : out std_logic
        );
    end component;

begin

    CMP : comparator_8bit
        port map (
            tot       => tot,
            s         => s,
            tot_gte_s => tot_gte_s,
            tot_eq_s  => tot_eq_s,
            tot_lt_s  => tot_lt_s
        );

end structural;