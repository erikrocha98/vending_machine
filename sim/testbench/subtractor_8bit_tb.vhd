library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_subtractor_8bit is
end entity tb_subtractor_8bit;

architecture testbench of tb_subtractor_8bit is
    
    component subtractor_8bit
        port (
            a     : in  std_logic_vector (7 downto 0);
            b     : in  std_logic_vector (7 downto 0);
            diff  : out std_logic_vector (7 downto 0);
            bout  : out std_logic
        );
    end component;
    
    signal a_tb, b_tb, diff_tb : std_logic_vector(7 downto 0);
    signal bout_tb : std_logic;
    
begin
    
    UUT: subtractor_8bit
        port map (
            a    => a_tb,
            b    => b_tb,
            diff => diff_tb,
            bout => bout_tb
        );
    
    process
    begin
        -- Teste 1: 10 - 5 = 5
        a_tb <= "00001010";  -- 10
        b_tb <= "00000101";  -- 5
        wait for 10 ns;
        
        -- Teste 2: 5 - 10 = -5 (com borrow)
        a_tb <= "00000101";  -- 5
        b_tb <= "00001010";  -- 10
        wait for 10 ns;
        
        -- Teste 3: 255 - 1 = 254
        a_tb <= "11111111";  -- 255
        b_tb <= "00000001";  -- 1
        wait for 10 ns;
        
        -- Teste 4: 100 - 100 = 0
        a_tb <= "01100100";  -- 100
        b_tb <= "01100100";  -- 100
        wait for 10 ns;
        
        wait;
    end process;
    
end architecture testbench;