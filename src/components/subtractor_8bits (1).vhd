-- ============================================
-- Projeto : Máquina de Vendas
-- Arquivo : subtractor_8bits.vhd
-- Autores : Erik Avelino e Malu Lauar
-- Descrição:
--   Subtrator de 8 bits:
--       a - b = a + (~b) + 1
--   Implementado com cadeia de Full Adders
--   Saídas:
--       diff = resultado
--       bout = borrow (1 quando a < b)
-- ============================================

library IEEE;
use IEEE.std_logic_1164.all;

entity subtractor_8bits is
    port (
        a     : in  std_logic_vector(7 downto 0);  -- minuendo
        b     : in  std_logic_vector(7 downto 0);  -- subtraendo
        diff  : out std_logic_vector(7 downto 0);  -- resultado
        bout  : out std_logic                      -- borrow out
    );
end subtractor_8bits;

architecture structural of subtractor_8bits is

    component full_adder
        port (
            a    : in  std_logic;
            b    : in  std_logic;
            cin  : in  std_logic;
            sum  : out std_logic;
            cout : out std_logic
        );
    end component;

    signal b_inv      : std_logic_vector(7 downto 0);  -- ~b
    signal c0, c1, c2, c3, c4, c5, c6 : std_logic;
    signal cout_final : std_logic;

begin

    -- Complemento de 1 do subtraendo
    b_inv <= not b;

    -- Ripple-Carry para a + (~b) + 1

    FA0: full_adder port map(a(0), b_inv(0), '1', diff(0), c0);
    FA1: full_adder port map(a(1), b_inv(1), c0, diff(1), c1);
    FA2: full_adder port map(a(2), b_inv(2), c1, diff(2), c2);
    FA3: full_adder port map(a(3), b_inv(3), c2, diff(3), c3);
    FA4: full_adder port map(a(4), b_inv(4), c3, diff(4), c4);
    FA5: full_adder port map(a(5), b_inv(5), c4, diff(5), c5);
    FA6: full_adder port map(a(6), b_inv(6), c5, diff(6), c6);

    FA7: full_adder port map(a(7), b_inv(7), c6, diff(7), cout_final);

    -- Borrow ocorre quando não há carry final
    bout <= not cout_final;

end structural;