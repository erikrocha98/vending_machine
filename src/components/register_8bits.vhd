-- ============================================
-- Projeto : Máquina de Vendas
-- Arquivo : register_8bits.vhd
-- Autores : Erik Avelino e Malu Lauar
-- Descrição:
--   Registrador de 8 bits construído com 8 D-Flip-Flops
--   Clear assíncrono + Load enable
-- ============================================

library IEEE;
use IEEE.std_logic_1164.all;

entity dff_enable is
    port (
        clk : in std_logic;
        clr : in std_logic;
        en  : in std_logic;
        d   : in std_logic;
        q   : out std_logic
    );
end dff_enable;

architecture behavioral of dff_enable is
begin
    process(clk, clr)
    begin
        if clr = '1' then
            q <= '0';
        elsif rising_edge(clk) then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process;
end behavioral;

-- =============================
-- Registrador de 8 bits
-- =============================
library IEEE;
use IEEE.std_logic_1164.all;

entity register_8bits is
    port (
        clk   : in std_logic;
        clr   : in std_logic;
        ld    : in std_logic;
        d_in  : in std_logic_vector(7 downto 0);
        q_out : out std_logic_vector(7 downto 0)
    );
end register_8bits;

architecture structural of register_8bits is
    component dff_enable
        port ( clk, clr, en, d : in std_logic; q : out std_logic );
    end component;
begin

    D0 : dff_enable port map(clk, clr, ld, d_in(0), q_out(0));
    D1 : dff_enable port map(clk, clr, ld, d_in(1), q_out(1));
    D2 : dff_enable port map(clk, clr, ld, d_in(2), q_out(2));
    D3 : dff_enable port map(clk, clr, ld, d_in(3), q_out(3));
    D4 : dff_enable port map(clk, clr, ld, d_in(4), q_out(4));
    D5 : dff_enable port map(clk, clr, ld, d_in(5), q_out(5));
    D6 : dff_enable port map(clk, clr, ld, d_in(6), q_out(6));
    D7 : dff_enable port map(clk, clr, ld, d_in(7), q_out(7));

end structural;