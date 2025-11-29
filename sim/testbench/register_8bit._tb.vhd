library IEEE;
use IEEE.std_logic_1164.all;

entity tb_reg_8bit is
end tb_reg_8bit;

architecture test of tb_reg_8bit is
    
    signal clk_test   : std_logic := '0';
    signal clr_test   : std_logic := '0';
    signal ld_test    : std_logic := '0';
    signal d_in_test  : std_logic_vector(7 downto 0) := "00000000";
    signal q_out_test : std_logic_vector(7 downto 0);
    
begin
    
    uut: entity work.reg_8bit
        port map (
            clk   => clk_test,
            clr   => clr_test,
            ld    => ld_test,
            d_in  => d_in_test,
            q_out => q_out_test
        );
    
    clk_test <= not clk_test after 10 ns when now < 200 ns else '0';
    
    process
    begin
        clr_test <= '1';
        wait for 30 ns;
        clr_test <= '0';
        wait for 20 ns;
        
        d_in_test <= "10101010";
        ld_test <= '1';
        wait for 20 ns;
        ld_test <= '0';
        wait for 100 ns;
        
        wait;
    end process;
    
end test;