-- ============================================
-- Projeto : Máquina de Vendas
-- Arquivo  : maquina_vendas_datapath.vhd
-- Autores  : Erik Avelino e Malu Lauar
-- Descrição:
--   Datapath estrutural da máquina de vendas.
--   Contém registradores, adder, subtractor, decrementer e comparadores.
--   O datapath expõe sinais de status para a controladora (FSM)
--   e aceita sinais de controle (ld, sel) vindos da controladora.
-- ============================================

library IEEE;
use IEEE.std_logic_1164.all;

entity maquina_vendas_datapath is
    port (
        -- clock / reset
        clk        : in  std_logic;
        clr_async  : in  std_logic;

        -- entradas externas (valores)
        coin_in    : in  std_logic_vector(7 downto 0); -- moeda/valor a somar
        price_in   : in  std_logic_vector(7 downto 0); -- valor do produto
        stock_in   : in  std_logic_vector(7 downto 0); -- valor para carregar estoque

        -- sinais de controle (da controladora)
        ld_tot     : in  std_logic;                     -- carrega tot_reg
        ld_preco   : in  std_logic;                     -- carrega preco_reg
        ld_estoque : in  std_logic;                     -- carrega estoque_reg
        ld_change  : in  std_logic;                     -- carrega change_reg

        sel_tot    : in  std_logic_vector(1 downto 0);  -- 00=tot_plus_coin, 01=troco, 10=zero, 11=hold
        sel_estoque: in  std_logic;                     -- '1' -> usar dec_estoque, '0' -> hold/stock_in used with ld
        sel_preco  : in  std_logic;                     -- '1' -> load external price when ld_preco='1'

        -- sinais de status para a controladora (datapath -> controller)
        tot_gte_price  : out std_logic;
        tot_eq_price   : out std_logic;
        tot_lt_price   : out std_logic;

        estoque_gt_0   : out std_logic;
        estoque_eq_0   : out std_logic;

        -- saídas finais (valores mantidos nos registradores)
        tot_out     : out std_logic_vector(7 downto 0);
        preco_out   : out std_logic_vector(7 downto 0);
        estoque_out : out std_logic_vector(7 downto 0);
        change_out  : out std_logic_vector(7 downto 0)
    );
end maquina_vendas_datapath;

architecture structural of maquina_vendas_datapath is

    component register_8bits
        port (
            clk   : in  std_logic;
            clr   : in  std_logic;
            ld    : in  std_logic;
            d_in  : in  std_logic_vector(7 downto 0);
            q_out : out std_logic_vector(7 downto 0)
        );
    end component;

    component ripple_carry_adder_8bit
        port (
            a    : in  std_logic_vector(7 downto 0);
            b    : in  std_logic_vector(7 downto 0);
            cin  : in  std_logic;
            cout : out std_logic;
            s    : out std_logic_vector(7 downto 0)
        );
    end component;

    component subtractor_8bits
        port (
            a    : in  std_logic_vector(7 downto 0);
            b    : in  std_logic_vector(7 downto 0);
            diff : out std_logic_vector(7 downto 0);
            bout : out std_logic
        );
    end component;

    component decrementer_8bits
        port (
            a   : in  std_logic_vector(7 downto 0);
            dec : out std_logic_vector(7 downto 0);
            bout: out std_logic
        );
    end component;

    component comparator_preco
        port (
            tot       : in  std_logic_vector(7 downto 0);
            s         : in  std_logic_vector(7 downto 0);
            tot_gte_s : out std_logic;
            tot_eq_s  : out std_logic;
            tot_lt_s  : out std_logic
        );
    end component;

    component comparator_estoque
        port (
            estoque      : in  std_logic_vector(7 downto 0);
            estoque_gt_0 : out std_logic;
            estoque_eq_0 : out std_logic
        );
    end component;


    -- Internal datapath signals
    signal tot_reg, preco_reg, estoque_reg, change_reg : std_logic_vector(7 downto 0);
    signal tot_plus_coin : std_logic_vector(7 downto 0);
    signal add_cout : std_logic;
    signal troco        : std_logic_vector(7 downto 0);
    signal troco_bout   : std_logic;
    signal dec_estoque  : std_logic_vector(7 downto 0);
    signal dec_bout     : std_logic;

    signal tot_mux_out  : std_logic_vector(7 downto 0);
    signal preco_mux_out: std_logic_vector(7 downto 0);
    signal estoque_mux_out: std_logic_vector(7 downto 0);
    signal change_mux_out: std_logic_vector(7 downto 0);

begin

    -- somador: tot_reg + coin_in -> tot_plus_coin
    ADDER : ripple_carry_adder_8bit
        port map (
            a    => tot_reg,
            b    => coin_in,
            cin  => '0',
            cout => add_cout,
            s    => tot_plus_coin
        );

    -- subtrator: troco = tot_reg - preco_reg
    SUBTR : subtractor_8bits
        port map (
            a    => tot_reg,
            b    => preco_reg,
            diff => troco,
            bout => troco_bout
        );

    -- decrementer: estoque - 1
    DEC : decrementer_8bits
        port map (
            a   => estoque_reg,
            dec => dec_estoque,
            bout=> dec_bout
        );


    -- sel_tot:
    --  "00" -> tot_plus_coin (usar quando inserir moeda)
    --  "01" -> troco         (usar quando compra com troco)
    --  "10" -> (others => '0') zero (usar quando zerar total após compra exata)
    --  "11" -> hold (reapresenta tot_reg, para manter valor se ld não ativo)
    with sel_tot select
        tot_mux_out <= tot_plus_coin when "00",
                       troco         when "01",
                       (others => '0') when "10",
                       tot_reg       when others;

    -- Preço: se sel_preco = '1' e ld_preco = '1' a controladora carrega price_in.
    preco_mux_out <= price_in when sel_preco = '1' else preco_reg;

    -- Estoque: se sel_estoque = '1' usar dec_estoque (decremento), else manter estoque_reg
    estoque_mux_out <= dec_estoque when sel_estoque = '1' else stock_in;

    -- Troco: controladora decide quando carregar troco no registrador de change
    change_mux_out <= troco when ld_change = '1' else change_reg;


    REG_TOT : register_8bits
        port map (
            clk   => clk,
            clr   => clr_async,
            ld    => ld_tot,
            d_in  => tot_mux_out,
            q_out => tot_reg
        );

    REG_PRECO : register_8bits
        port map (
            clk   => clk,
            clr   => clr_async,
            ld    => ld_preco,
            d_in  => preco_mux_out,
            q_out => preco_reg
        );

    REG_ESTOQUE : register_8bits
        port map (
            clk   => clk,
            clr   => clr_async,
            ld    => ld_estoque,
            d_in  => estoque_mux_out,
            q_out => estoque_reg
        );

    REG_CHANGE : register_8bits
        port map (
            clk   => clk,
            clr   => clr_async,
            ld    => ld_change,
            d_in  => change_mux_out,
            q_out => change_reg
        );


    CMP_PRECO : comparator_preco
        port map (
            tot       => tot_reg,
            s         => preco_reg,
            tot_gte_s => tot_gte_price,
            tot_eq_s  => tot_eq_price,
            tot_lt_s  => tot_lt_price
        );

    CMP_ESTOQUE : comparator_estoque
        port map (
            estoque      => estoque_reg,
            estoque_gt_0 => estoque_gt_0,
            estoque_eq_0 => estoque_eq_0
        );


    tot_out     <= tot_reg;
    preco_out   <= preco_reg;
    estoque_out <= estoque_reg;
    change_out  <= change_reg;

end architecture structural;