-- ============================================
-- Projeto : Máquina de Vendas
-- Arquivo : maquina_vendas_controller.vhd
-- Autores : Erik Avelino e Malu Lauar
-- Descrição:
--   Controladora (FSM) da máquina de vendas.
--   Gera sinais de controle para o datapath
--   com base nas condições de preço e estoque.
--   FSM simples e robusta.
-- ============================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity maquina_vendas_controller is
    port (
        clk       : in  std_logic;
        clr_async : in  std_logic;

        -- Entradas
        coin_insert : in  std_logic;  
        buy         : in  std_logic;   
        price_load  : in  std_logic;    
        stock_load  : in  std_logic;   

        -- Status do Datapath
        tot_gte_price : in std_logic;   
        estoque_gt_0  : in std_logic; 

        -- Controle do Datapath
        ld_tot     : out std_logic;
        ld_preco   : out std_logic;
        ld_estoque : out std_logic;
        ld_change  : out std_logic;

        sel_tot      : out std_logic_vector(1 downto 0);
        sel_estoque  : out std_logic;
        sel_preco    : out std_logic;

        -- Saídas Finais (Diagrama)
        dispense     : out std_logic;  
        change_valid : out std_logic; 
        msg_error    : out std_logic    
    );
end entity;

architecture behavioral of maquina_vendas_controller is

    -- Estados do Diagrama FSM
    type state_type is (
        ST_INIT,    -- Estado inicial (zera tudo)
        ST_WAIT,    -- Esperando 'select' ou 'c'
        ST_ADD,     -- Soma moeda (tot = tot + a)
        ST_DISP,    -- Dispensa (d=1, estoque--, troco=tot-s)
        ST_CHANGE,  -- Entrega troco (troco_out=1, tot=0)
        ST_ERROR    -- Erro de estoque (msg=1)
    );

    signal state, next_state : state_type;

begin

    -- Registro de Estado
    process(clk, clr_async)
    begin
        if clr_async = '1' then
            state <= ST_INIT;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Lógica de Próximo Estado
    process(state, coin_insert, buy, tot_gte_price, estoque_gt_0, price_load, stock_load)
    begin
        next_state <= state;

        case state is
            -- INIT: Estado inicial (seta defaults e vai para WAIT)
            when ST_INIT =>
                next_state <= ST_WAIT;

            -- WAIT: Aguarda inputs
            when ST_WAIT =>
                -- Prioridade para configurações (Load Price/Stock) para funcionar na placa
                if price_load = '1' or stock_load = '1' then
                    next_state <= ST_WAIT; 
                
                -- Lógica do Diagrama: 'c' leva ao ADD
                elsif coin_insert = '1' then
                    next_state <= ST_ADD;

                -- Lógica do Diagrama: 'select' leva a decisão
                elsif buy = '1' then
                    -- Se Estoque = 0 E Saldo >= Preço -> ERROR
                    if (estoque_gt_0 = '0') and (tot_gte_price = '1') then
                        next_state <= ST_ERROR;
                    
                    -- Se Estoque > 0 E Saldo >= Preço -> DISP
                    elsif (estoque_gt_0 = '1') and (tot_gte_price = '1') then
                        next_state <= ST_DISP;
                    
                    -- Se Saldo < Preço fica em WAIT.
                    else
                        next_state <= ST_WAIT;
                    end if;
                end if;

            -- ADD: Soma a moeda e volta para WAIT
            when ST_ADD =>
                next_state <= ST_WAIT;

            -- DISP: Executa compra e vai para CHANGE
            when ST_DISP =>
                next_state <= ST_CHANGE;

            -- CHANGE: Mostra troco e vai para INIT
            when ST_CHANGE =>
                next_state <= ST_INIT;

            -- ERROR: Mostra msg e volta para WAIT
            when ST_ERROR =>
                next_state <= ST_WAIT;

        end case;
    end process;

    -- Saídas de Controle
    process(state, price_load, stock_load, tot_gte_price)
    begin
        ld_tot     <= '0';
        ld_preco   <= '0';
        ld_estoque <= '0';
        ld_change  <= '0';
        sel_tot    <= "11"; -- Hold
        sel_estoque<= '0';
        sel_preco  <= '0';
        
        -- Saídas do diagrama
        dispense     <= '0'; -- d
        change_valid <= '0'; -- troco_out
        msg_error    <= '0'; -- msg

        case state is
            when ST_INIT =>
                -- Diagrama: d=0, tot=0, troco=0
                ld_tot <= '1';
                sel_tot <= "10"; -- Zera Total
                ld_change <= '1'; -- Carrega 0
                
            when ST_WAIT =>
                if price_load = '1' then
                    ld_preco <= '1';
                    sel_preco <= '1';
                end if;
                if stock_load = '1' then
                    ld_estoque <= '1';
                end if;

            when ST_ADD =>
                -- Diagrama: tot = tot + a
                ld_tot <= '1';
                sel_tot <= "00"; -- Soma coin_in

            when ST_DISP =>
                -- Diagrama: d=1
                dispense <= '1';
                
                -- Diagrama: estoque = estoque - 1
                ld_estoque <= '1';
                sel_estoque <= '1'; -- Decrementa

                -- Diagrama: troco = tot - s 
                ld_tot <= '1';
                
                -- Se tot >= price, guardamos o troco.
                sel_tot <= "01"; -- Resultado do troco
                
                -- Também carregamos o registrador de CHANGE para display estável
                ld_change <= '1';

            when ST_CHANGE =>
                change_valid <= '1';
              

            when ST_ERROR =>
                msg_error <= '1';

        end case;
    end process;

end architecture;