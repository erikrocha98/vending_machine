-- ============================================
-- Projeto : Máquina de Vendas
-- Arquivo : comparator_estoque.vhd
-- Autores : Erik Avelino e Malu Lauar
-- Descrição:
--   Comparador estrutural:
--      estoque_eq_0 = NOR de todos os bits
--      estoque_gt_0 = NOT(estoque_eq_0)
-- ============================================

library IEEE;
use IEEE.std_logic_1164.all;

entity comparator_estoque is
    port (
        estoque      : in  std_logic_vector(7 downto 0);
        estoque_gt_0 : out std_logic;
        estoque_eq_0 : out std_logic
    );
end comparator_estoque;

architecture structural of comparator_estoque is

    signal nor1, nor2, nor3, nor4 : std_logic;
    signal all_zero : std_logic;

begin

    -- NOR por pares
    nor1 <= estoque(0) nor estoque(1);
    nor2 <= estoque(2) nor estoque(3);
    nor3 <= estoque(4) nor estoque(5);
    nor4 <= estoque(6) nor estoque(7);

    -- Se todos os pares são zero → estoque = 0
    all_zero <= nor1 and nor2 and nor3 and nor4;

    estoque_eq_0 <= all_zero;
    estoque_gt_0 <= not all_zero;

end structural;