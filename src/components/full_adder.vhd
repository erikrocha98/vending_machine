-- ============================================
-- Projeto: Máquina de Vendas
-- Arquivo : full_adder.vhd
-- Autores : Erik Avelino e Malu Lauar
-- Descrição:
--   Somador completo (Full Adder) de 1 bit
--   Implementação estrutural com portas lógicas
-- ============================================

library IEEE;
use IEEE.std_logic_1164.all;

entity full_adder is
    port (
        a    : in  std_logic;   -- bit A
        b    : in  std_logic;   -- bit B
        cin  : in  std_logic;   -- carry in
        sum  : out std_logic;   -- bit de soma
        cout : out std_logic    -- carry out
    );
end full_adder;

architecture structural of full_adder is
begin
    -- Soma
    sum <= a xor b xor cin;

    -- Carry
    cout <= (a and b) or
            (cin and (a xor b));
end structural;