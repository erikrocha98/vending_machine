-- ============================================
-- Projeto : Máquina de Vendas
-- Arquivo : maquina_vendas_top.vhd
-- Autores : Erik Avelino e Malu Lauar
-- Descrição:
--   Top-level que integra a Controladora (FSM)
--   e o Datapath estrutural da máquina de vendas.
-- ============================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity maquina_vendas_top is
    port (
        clk        : in  std_logic;
        clr_async  : in  std_logic;

        coin_in    : in  std_logic_vector(7 downto 0);
        load_coin  : in  std_logic;

        price_in   : in  std_logic_vector(7 downto 0);
        load_price : in  std_logic;

        stock_in   : in  std_logic_vector(7 downto 0);
        load_stock : in std_logic;

        buy        : in  std_logic;

        dispense       : out std_logic;
        change_out     : out std_logic_vector(7 downto 0);
        change_valid   : out std_logic;
        msg_error      : out std_logic;

        -- debug
        tot_out     : out std_logic_vector(7 downto 0);
        preco_out   : out std_logic_vector(7 downto 0);
        estoque_out : out std_logic_vector(7 downto 0)
    );
end entity maquina_vendas_top;

architecture structural of maquina_vendas_top is

    component maquina_vendas_datapath
        port (
            clk        : in  std_logic;
            clr_async  : in  std_logic;

            coin_in    : in  std_logic_vector(7 downto 0);
            price_in   : in  std_logic_vector(7 downto 0);
            stock_in   : in  std_logic_vector(7 downto 0);

            ld_tot     : in  std_logic;
            ld_preco   : in  std_logic;
            ld_estoque : in  std_logic;
            ld_change  : in  std_logic;

            sel_tot    : in std_logic_vector(1 downto 0);
            sel_estoque: in std_logic;
            sel_preco  : in std_logic;

            tot_gte_price : out std_logic;
            tot_eq_price  : out std_logic;
            tot_lt_price  : out std_logic;

            estoque_gt_0  : out std_logic;
            estoque_eq_0  : out std_logic;

            tot_out     : out std_logic_vector(7 downto 0);
            preco_out   : out std_logic_vector(7 downto 0);
            estoque_out : out std_logic_vector(7 downto 0);
            change_out  : out std_logic_vector(7 downto 0)
        );
    end component;

    component maquina_vendas_controller
        port (
            clk       : in  std_logic;
            clr_async : in  std_logic;

            coin_insert : in  std_logic;
            buy         : in  std_logic;
            price_load  : in  std_logic;
            stock_load  : in  std_logic;

            tot_gte_price : in std_logic;
            estoque_gt_0  : in std_logic;

            ld_tot     : out std_logic;
            ld_preco   : out std_logic;
            ld_estoque : out std_logic;
            ld_change  : out std_logic;

            sel_tot      : out std_logic_vector(1 downto 0);
            sel_estoque  : out std_logic;
            sel_preco    : out std_logic;

            dispense     : out std_logic;
            change_valid : out std_logic;
            msg_error    : out std_logic   
        );
    end component;

    -- sinais internos
    signal sig_ld_tot, sig_ld_preco, sig_ld_estoque, sig_ld_change : std_logic;
    signal sig_sel_tot      : std_logic_vector(1 downto 0);
    signal sig_sel_estoque  : std_logic;
    signal sig_sel_preco    : std_logic;

    signal sig_tot_gte_price, sig_tot_eq_price, sig_tot_lt_price : std_logic;
    signal sig_estoque_gt_0, sig_estoque_eq_0 : std_logic;

    signal sig_tot_out, sig_preco_out, sig_estoque_out, sig_change_out : std_logic_vector(7 downto 0);

    signal sig_msg_error : std_logic;

begin

    -------------------------------------------------------
    --  CONTROLADORA
    -------------------------------------------------------
    CTRL: maquina_vendas_controller
        port map (
            clk           => clk,
            clr_async     => clr_async,

            coin_insert   => load_coin,   -- pulso
            buy           => buy,
            price_load    => load_price,
            stock_load    => load_stock,

            tot_gte_price => sig_tot_gte_price,
            estoque_gt_0  => sig_estoque_gt_0,

            ld_tot        => sig_ld_tot,
            ld_preco      => sig_ld_preco,
            ld_estoque    => sig_ld_estoque,
            ld_change     => sig_ld_change,

            sel_tot       => sig_sel_tot,
            sel_estoque   => sig_sel_estoque,
            sel_preco     => sig_sel_preco,

            dispense      => dispense,
            change_valid  => change_valid,
            msg_error     => sig_msg_error
        );

    -------------------------------------------------------
    --  DATAPATH
    -------------------------------------------------------
    DP: maquina_vendas_datapath
        port map (
            clk           => clk,
            clr_async     => clr_async,

            coin_in       => coin_in,
            price_in      => price_in,
            stock_in      => stock_in,

            ld_tot        => sig_ld_tot,
            ld_preco      => sig_ld_preco,
            ld_estoque    => sig_ld_estoque,
            ld_change     => sig_ld_change,

            sel_tot       => sig_sel_tot,
            sel_estoque   => sig_sel_estoque,
            sel_preco     => sig_sel_preco,

            tot_gte_price => sig_tot_gte_price,
            tot_eq_price  => sig_tot_eq_price,
            tot_lt_price  => sig_tot_lt_price,

            estoque_gt_0  => sig_estoque_gt_0,
            estoque_eq_0  => sig_estoque_eq_0,

            tot_out       => sig_tot_out,
            preco_out     => sig_preco_out,
            estoque_out   => sig_estoque_out,
            change_out    => sig_change_out
        );

    -------------------------------------------------------
    --  EXTERNAL OUTPUTS
    -------------------------------------------------------
    tot_out     <= sig_tot_out;
    preco_out   <= sig_preco_out;
    estoque_out <= sig_estoque_out;
    change_out  <= sig_change_out;

    msg_error   <= sig_msg_error;
end architecture structural;