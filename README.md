# 🏧 Máquina de Vendas em VHDL

Uma máquina de vendas digital implementada em VHDL para FPGA DE10-Lite, desenvolvida como projeto acadêmico de Sistemas Digitais.

![VHDL](https://img.shields.io/badge/VHDL-blue?style=flat-square)
![FPGA](https://img.shields.io/badge/FPGA-DE10--Lite-orange?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

## 📋 Sobre o Projeto

Este projeto simula o funcionamento de uma vending machine, permitindo:
- Inserir moedas e acumular crédito
- Configurar preço do produto e estoque inicial
- Realizar compras com cálculo automático de troco
- Controle de estoque com proteção contra venda sem produto

A implementação segue arquitetura **Controller + Datapath** com construção **totalmente estrutural** dos componentes aritméticos.

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────┐
│              FPGA WRAPPER (DE10-Lite)                   │
│         Botões | Switches | LEDs | Displays             │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                     TOP LEVEL                           │
│                                                         │
│   ┌─────────────┐    sinais     ┌─────────────────┐    │
│   │ CONTROLLER  │◄─────────────►│    DATAPATH     │    │
│   │    (FSM)    │   controle    │                 │    │
│   │             │   + status    │  Registradores  │    │
│   │  6 estados  │               │  Somador        │    │
│   │             │               │  Subtrator      │    │
│   └─────────────┘               │  Comparadores   │    │
│                                 └─────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

## 📁 Estrutura de Arquivos

```
├── full_adder.vhd                 # Somador completo de 1 bit
├── ripple_carry_adder_8bit.vhd    # Somador 8 bits (8x Full Adder)
├── subtractor_8bits.vhd           # Subtrator 8 bits (complemento de 2)
├── decrementer_8bits.vhd          # Decrementador (x - 1)
├── register_8bits.vhd             # Registrador 8 bits com enable
├── comparator_8bit.vhd            # Comparador genérico 8 bits
├── comparator_preco.vhd           # Comparador total vs preço
├── comparator_estoque.vhd         # Comparador estoque vs zero
├── datapath.vhd                   # Datapath completo
├── controller.vhd                 # FSM controladora
├── maquina_vendas_top.vhd         # Top-level do sistema
└── maquina_vendas_fpga_wrapper.vhd # Interface com DE10-Lite
```

## ⚙️ Componentes

### Datapath
| Componente | Descrição |
|------------|-----------|
| Registrador Total | Armazena valor acumulado de moedas |
| Registrador Preço | Armazena preço do produto |
| Registrador Estoque | Armazena quantidade disponível |
| Registrador Troco | Armazena valor do troco |
| Ripple Carry Adder | Soma moeda ao total |
| Subtrator | Calcula troco (total - preço) |
| Decrementador | Reduz estoque após venda |
| Comparadores | Verificam condições (total ≥ preço, estoque > 0) |

### Máquina de Estados (FSM)

```
         ┌──────────┐
 reset ──►│ ST_INIT  │
         └────┬─────┘
              ▼
       ┌► ST_WAIT ◄──────────────┐
       │     │                   │
       │  coin/buy/load          │
       │     │                   │
       │     ▼                   │
       │ ┌───────┐               │
       └─┤ST_ADD │               │
         └───────┘               │
              │                  │
         buy + condições         │
              │                  │
      ┌───────┴───────┐          │
      ▼               ▼          │
  ST_DISP         ST_ERROR ──────┤
      │                          │
      ▼                          │
  ST_CHANGE ─────────────────────┘
```

| Estado | Descrição |
|--------|-----------|
| `ST_INIT` | Inicializa sistema, zera registradores |
| `ST_WAIT` | Aguarda entrada do usuário |
| `ST_ADD` | Adiciona moeda ao total |
| `ST_DISP` | Dispensa produto, decrementa estoque |
| `ST_CHANGE` | Exibe troco calculado |
| `ST_ERROR` | Sinaliza erro (sem estoque) |

## 🎮 Interface DE10-Lite

### Entradas

| Elemento | Função |
|----------|--------|
| `KEY[1]` | Clock (pulso manual) |
| `KEY[0]` | Reset assíncrono |
| `SW[7:0]` | Valor de entrada (8 bits) |
| `SW[9:8]` | Seletor de modo |

### Modos de Operação

| SW[9:8] | Modo | Ação |
|---------|------|------|
| `00` | Comprar | SW[0] = 1 para confirmar compra |
| `01` | Preço | Carrega SW[7:0] como preço |
| `10` | Estoque | Carrega SW[7:0] como estoque |
| `11` | Moeda | Adiciona SW[7:0] ao total |

### Saídas

| Elemento | Informação |
|----------|------------|
| `HEX0-HEX1` | Total inserido |
| `HEX2-HEX3` | Preço do produto |
| `HEX4-HEX5` | Estoque disponível |
| `LEDR[9]` | Troco disponível |
| `LEDR[8]` | Produto dispensado |
| `LEDR[7]` | Erro (sem estoque) |

## 🚀 Como Usar

### Pré-requisitos
- Intel Quartus Prime (Lite Edition)
- FPGA DE10-Lite

### Compilação e Programação

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/maquina-vendas-vhdl.git
```

2. Abra o Quartus Prime e crie um novo projeto

3. Adicione todos os arquivos `.vhd` ao projeto

4. Defina `maquina_vendas_fpga_wrapper` como top-level entity

5. Configure os pinos conforme a DE10-Lite (Pin Planner)

6. Compile e programe a FPGA

### Sequência de Teste

```
1. Pressione KEY[0] para reset

2. Configure o preço:
   - SW[9:8] = "01"
   - SW[7:0] = preço desejado (ex: 00001010 = 10)
   - Pulse KEY[1]

3. Configure o estoque:
   - SW[9:8] = "10"
   - SW[7:0] = quantidade (ex: 00000101 = 5)
   - Pulse KEY[1]

4. Insira moedas:
   - SW[9:8] = "11"
   - SW[7:0] = valor da moeda
   - Pulse KEY[1] para cada inserção

5. Realize a compra:
   - SW[9:8] = "00"
   - SW[0] = "1"
   - Pulse KEY[1]
```

## 📊 Exemplo de Operação

| Passo | Ação | Total | Preço | Estoque | Resultado |
|-------|------|-------|-------|---------|-----------|
| 1 | Reset | 00 | 00 | 00 | Sistema zerado |
| 2 | Carregar preço = 10 | 00 | 10 | 00 | - |
| 3 | Carregar estoque = 5 | 00 | 10 | 05 | - |
| 4 | Inserir moeda = 7 | 07 | 10 | 05 | - |
| 5 | Inserir moeda = 5 | 12 | 10 | 05 | - |
| 6 | Comprar | 02 | 10 | 04 | Dispensa + Troco = 2 |

## 🛠️ Tecnologias

- **Linguagem:** VHDL
- **IDE:** Intel Quartus Prime
- **Hardware:** FPGA Intel MAX 10 (DE10-Lite)
- **Metodologia:** Design estrutural hierárquico

## 👥 Autores

- **Erik Avelino**
- **Malu Lauar**

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🙏 Agradecimentos

- Professores da disciplina de Sistemas Digitais
- Intel/Altera pela plataforma DE10-Lite
- Comunidade VHDL pelos recursos de aprendizado

---

⭐ Se este projeto foi útil, considere dar uma estrela!