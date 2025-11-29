library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_adder_8bit is
end entity tb_adder_8bit;

architecture testbench of tb_adder_8bit is
    
    component ripple_carry_adder_8bit
        port (
            a    : in  std_logic_vector (7 downto 0);
            b    : in  std_logic_vector (7 downto 0);
            cin  : in  std_logic;
            cout : out std_logic;
            s    : out std_logic_vector (7 downto 0)
        );
    end component;
    
    signal a_tb, b_tb, s_tb : std_logic_vector(7 downto 0);
    signal cin_tb, cout_tb : std_logic;
    
begin
    
    UUT: ripple_carry_adder_8bit
        port map (
            a    => a_tb,
            b    => b_tb,
            cin  => cin_tb,
            cout => cout_tb,
            s    => s_tb
        );
    
    process
    begin
        -- Teste 1: 5 + 3 = 8
        a_tb <= "00000101";  -- 5
        b_tb <= "00000011";  -- 3
        cin_tb <= '0';
        wait for 10 ns;
        
        -- Teste 2: 255 + 1 = 256 (overflow)
        a_tb <= "11111111";  -- 255
        b_tb <= "00000001";  -- 1
        cin_tb <= '0';
        wait for 10 ns;
        
        -- Teste 3: 127 + 127 = 254
        a_tb <= "01111111";  -- 127
        b_tb <= "01111111";  -- 127
        cin_tb <= '0';
        wait for 10 ns;
        
        -- Teste 4: Com carry in
        a_tb <= "00000001";  -- 1
        b_tb <= "00000001";  -- 1
        cin_tb <= '1';       -- +1
        wait for 10 ns;      -- = 3
        
        wait;
    end process;
    
end architecture testbench;