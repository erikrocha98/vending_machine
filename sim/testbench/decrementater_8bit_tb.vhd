library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_decrementer is
end entity;

architecture testbench of tb_decrementer is
    
    signal a_tb, dec_tb : std_logic_vector(7 downto 0);
    signal bout_tb : std_logic;
    
begin
    
    UUT: entity work.decrementer_8bit
        port map (
            a    => a_tb,
            dec  => dec_tb,
            bout => bout_tb
        );
    
    process
    begin
        report "===== Iniciando testes do Decrementador =====" severity note;
        
        -- Teste 1: 10 - 1 = 9
        a_tb <= "00001010";  -- 10
        wait for 10 ns;
        assert dec_tb = "00001001" 
            report "ERRO: 10-1 deve ser 9, obtido: " & 
                   integer'image(to_integer(unsigned(dec_tb))) 
            severity error;
        assert bout_tb = '0' 
            report "ERRO: 10-1 não deveria ter borrow" 
            severity error;
        report "Teste 1 OK: 10 - 1 = 9" severity note;
        
        -- Teste 2: 1 - 1 = 0
        a_tb <= "00000001";  -- 1
        wait for 10 ns;
        assert dec_tb = "00000000" 
            report "ERRO: 1-1 deve ser 0" 
            severity error;
        assert bout_tb = '0' 
            report "ERRO: 1-1 não deveria ter borrow" 
            severity error;
        report "Teste 2 OK: 1 - 1 = 0" severity note;
        
        -- Teste 3: 0 - 1 = 255 (underflow com borrow)
        a_tb <= "00000000";  -- 0
        wait for 10 ns;
        assert dec_tb = "11111111" 
            report "ERRO: 0-1 deve ser 255 (underflow)" 
            severity error;
        assert bout_tb = '1' 
            report "ERRO: 0-1 DEVERIA ter borrow" 
            severity error;
        report "Teste 3 OK: 0 - 1 = 255 (com borrow)" severity note;
        
        -- Teste 4: 255 - 1 = 254
        a_tb <= "11111111";  -- 255
        wait for 10 ns;
        assert dec_tb = "11111110" 
            report "ERRO: 255-1 deve ser 254" 
            severity error;
        assert bout_tb = '0' 
            report "ERRO: 255-1 não deveria ter borrow" 
            severity error;
        report "Teste 4 OK: 255 - 1 = 254" severity note;
        
        -- Teste 5: 128 - 1 = 127
        a_tb <= "10000000";  -- 128
        wait for 10 ns;
        assert dec_tb = "01111111" 
            report "ERRO: 128-1 deve ser 127" 
            severity error;
        assert bout_tb = '0' 
            report "ERRO: 128-1 não deveria ter borrow" 
            severity error;
        report "Teste 5 OK: 128 - 1 = 127" severity note;
        
        -- Teste 6: 100 - 1 = 99
        a_tb <= "01100100";  -- 100
        wait for 10 ns;
        assert dec_tb = "01100011" 
            report "ERRO: 100-1 deve ser 99" 
            severity error;
        report "Teste 6 OK: 100 - 1 = 99" severity note;
        
        -- Teste 7: 2 - 1 = 1
        a_tb <= "00000010";  -- 2
        wait for 10 ns;
        assert dec_tb = "00000001" 
            report "ERRO: 2-1 deve ser 1" 
            severity error;
        report "Teste 7 OK: 2 - 1 = 1" severity note;
        
        report "===== TODOS OS TESTES PASSARAM! =====" severity note;
        wait;
    end process;
    
end architecture testbench;