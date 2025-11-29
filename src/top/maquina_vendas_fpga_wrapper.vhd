library IEEE;
use IEEE.std_logic_1164.all;

entity maquina_vendas_fpga_wrapper is
    port (
        -- Entradas Físicas
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(1 downto 0);
        SW       : in  std_logic_vector(9 downto 0);

        -- Saídas Físicas
        LEDR     : out std_logic_vector(9 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(7 downto 0)
    );
end entity;

architecture structural of maquina_vendas_fpga_wrapper is

    -- Sinais internos para conectar placa -> Top Level
    signal clk_manual   : std_logic;
    signal rst_inverted : std_logic;
    
    -- Sinais de controle decodificados dos Switches
    signal load_coin    : std_logic;
    signal load_price   : std_logic;
    signal load_stock   : std_logic;
    signal buy_signal   : std_logic;

    -- Sinais de saída vindos do Top Level
    signal w_dispense     : std_logic;
    signal w_change_valid : std_logic;
    signal w_msg_error    : std_logic;
    signal w_change_out   : std_logic_vector(7 downto 0); -- (Não exibido nos HEX, mas disponível)
    
    signal w_tot_out      : std_logic_vector(7 downto 0);
    signal w_preco_out    : std_logic_vector(7 downto 0);
    signal w_estoque_out  : std_logic_vector(7 downto 0);

    -- Declaração do Top Level
    component maquina_vendas_top
        port (
            clk, clr_async : in std_logic;
            coin_in, price_in, stock_in : in std_logic_vector(7 downto 0);
            load_coin, load_price, load_stock, buy : in std_logic;
            dispense, change_valid, msg_error : out std_logic;
            change_out : out std_logic_vector(7 downto 0);
            tot_out, preco_out, estoque_out : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Declaração do Decoder de Display
    component hex7seg
        port ( bin : in std_logic_vector(3 downto 0); seg : out std_logic_vector(7 downto 0) );
    end component;

begin

    -- ADAPTAÇÃO FÍSICA 
    clk_manual   <= NOT KEY(1); -- Clock no botão
    rst_inverted <= NOT KEY(0); -- Reset no botão

    -- DECODIFICAÇÃO DE ENTRADA
    process(SW)
    begin
        load_coin  <= '0'; load_price <= '0'; load_stock <= '0'; buy_signal <= '0';
        case SW(9 downto 8) is
            when "00" => buy_signal <= SW(0);
            when "01" => load_price <= '1';
            when "10" => load_stock <= '1';
            when "11" => load_coin  <= '1';
            when others => null;
        end case;
    end process;

    -- INSTÂNCIA DO SISTEMA
    U_SYSTEM : maquina_vendas_top
        port map (
            clk        => clk_manual,
            clr_async  => rst_inverted,
            
            -- Dados compartilhados: todos leem SW[7..0], mas só o LOAD ativo grava
            coin_in    => SW(7 downto 0),
            price_in   => SW(7 downto 0),
            stock_in   => SW(7 downto 0),
            
            load_coin  => load_coin,
            load_price => load_price,
            load_stock => load_stock,
            buy        => buy_signal,
            
            dispense     => w_dispense,
            change_valid => w_change_valid,
            msg_error    => w_msg_error,
            change_out   => w_change_out,
            
            tot_out      => w_tot_out,
            preco_out    => w_preco_out,
            estoque_out  => w_estoque_out
        );

    -- SAÍDAS VISUAIS 
    LEDR(9) <= w_change_valid;
    LEDR(8) <= w_dispense;
    LEDR(7) <= w_msg_error;
    LEDR(6 downto 0) <= (others => '0');

    -- Total
    H0: hex7seg port map (w_tot_out(3 downto 0), HEX0);
    H1: hex7seg port map (w_tot_out(7 downto 4), HEX1);
    -- Preço
    H2: hex7seg port map (w_preco_out(3 downto 0), HEX2);
    H3: hex7seg port map (w_preco_out(7 downto 4), HEX3);
    -- Estoque
    H4: hex7seg port map (w_estoque_out(3 downto 0), HEX4);
    H5: hex7seg port map (w_estoque_out(7 downto 4), HEX5);

end architecture;