-- ============================================
-- Projeto : Máquina de Vendas
-- Arquivo : ripple_carry_adder_8bit.vhd
-- Autores : Erik Avelino e Malu Lauar
-- Descrição:
--   Somador Ripple-Carry de 8 bits
--   Construído com 8 full adders encadeados
-- ============================================

library IEEE;
use IEEE.std_logic_1164.all;

entity ripple_carry_adder_8bit is
    port (
        a    : in  std_logic_vector(7 downto 0);  -- entrada A
        b    : in  std_logic_vector(7 downto 0);  -- entrada B
        cin  : in  std_logic;                      -- carry in
        cout : out std_logic;                      -- carry out final
        s    : out std_logic_vector(7 downto 0)    -- soma
    );
end entity ripple_carry_adder_8bit;

architecture structural of ripple_carry_adder_8bit is

    component full_adder
        port (
            a    : in  std_logic;
            b    : in  std_logic;
            cin  : in  std_logic;
            sum  : out std_logic;
            cout : out std_logic
        );
    end component;

    -- sinais internos de carry
    signal c0, c1, c2, c3, c4, c5, c6 : std_logic;

begin

    -- Menor bit
    FA0 : full_adder port map(a(0), b(0), cin, s(0), c0);
    FA1 : full_adder port map(a(1), b(1), c0,  s(1), c1);
    FA2 : full_adder port map(a(2), b(2), c1,  s(2), c2);
    FA3 : full_adder port map(a(3), b(3), c2,  s(3), c3);
    FA4 : full_adder port map(a(4), b(4), c3,  s(4), c4);
    FA5 : full_adder port map(a(5), b(5), c4,  s(5), c5);
    FA6 : full_adder port map(a(6), b(6), c5,  s(6), c6);

    -- Maior bit
    FA7 : full_adder port map(a(7), b(7), c6,  s(7), cout);

end architecture structural;