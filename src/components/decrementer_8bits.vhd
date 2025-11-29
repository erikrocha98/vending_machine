-- ============================================
-- Projeto : Máquina de Vendas
-- Arquivo : decrementer_8bits.vhd
-- Autores : Erik Avelino e Malu Lauar
-- Descrição:
--   Decrementador de 8 bits:
--       a - 1 = a + 11111111 + 0
--   Implementado com cadeia de Full Adders
-- ============================================

library IEEE;
use IEEE.std_logic_1164.all;

entity decrementer_8bits is
    port (
        a    : in  std_logic_vector(7 downto 0);   -- entrada
        dec  : out std_logic_vector(7 downto 0);   -- a - 1
        bout : out std_logic                       -- borrow out
    );
end decrementer_8bits;

architecture structural of decrementer_8bits is

    component full_adder
        port (
            a    : in  std_logic;
            b    : in  std_logic;
            cin  : in  std_logic;
            sum  : out std_logic;
            cout : out std_logic
        );
    end component;

    signal c0, c1, c2, c3, c4, c5, c6 : std_logic;
    signal cout_final : std_logic;

begin

    -- LSB: soma a(0) + 1 + 0
    FA0: full_adder port map(a(0), '1', '0', dec(0), c0);

    -- Demais bits somam: a(i) + 1 + carry anterior
    FA1: full_adder port map(a(1), '1', c0, dec(1), c1);
    FA2: full_adder port map(a(2), '1', c1, dec(2), c2);
    FA3: full_adder port map(a(3), '1', c2, dec(3), c3);
    FA4: full_adder port map(a(4), '1', c3, dec(4), c4);
    FA5: full_adder port map(a(5), '1', c4, dec(5), c5);
    FA6: full_adder port map(a(6), '1', c5, dec(6), c6);

    -- MSB
    FA7: full_adder port map(a(7), '1', c6, dec(7), cout_final);

    -- Borrow = NOT carry final
    bout <= not cout_final;

end structural;