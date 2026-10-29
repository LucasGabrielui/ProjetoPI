# Fluxograma — Estoque Tributável da Pizzaria (RASCUNHO da IA)

> Rascunho para estudo. Passe para a ferramenta que o professor pede, desenhando você mesmo.
> Para ver o desenho: cole cada bloco em https://mermaid.live
>
> Símbolos: `([ ])` = início/fim · `[ ]` = processo · `{ }` = decisão · `[/ /]` = entrada/saída de dados

## 1. Programa principal (menu)

```mermaid
flowchart TD
    A([Início]) --> B["opcao = -1"]
    B --> C{"opcao != 0 ?"}
    C -- Não --> Z([Fim])
    C -- Sim --> D[/"Mostrar painel: total de produtos,<br/>movimentações e alerta de estoque baixo"/]
    D --> E[/"Ler opção (0 a 7) com leitura segura"/]
    E --> F{"Qual opção?"}
    F -- 1 --> G1["Cadastrar produto"]
    F -- 2 --> G2["Listar produtos"]
    F -- 3 --> G3["Editar produto"]
    F -- 4 --> G4["Registrar entrada"]
    F -- 5 --> G5["Registrar saída"]
    F -- 6 --> G6["Relatório e impostos"]
    F -- 7 --> G7["Histórico"]
    F -- 0 --> G0[/"Sistema encerrado"/]
    G1 & G2 & G3 & G4 & G5 & G6 & G7 & G0 --> C
```

## 2. Leitura segura de número (não deixa o sistema travar)

```mermaid
flowchart TD
    A([Início ler_real]) --> B[/"Mostrar mensagem e ler TEXTO"/]
    B --> C["Trocar vírgula por ponto"]
    C --> D{"Texto é um número?"}
    D -- Não --> F[/"Valor inválido. Digite um número entre mínimo e máximo"/]
    D -- Sim --> E{"mínimo <= valor <= máximo ?"}
    E -- Não --> F
    F --> B
    E -- Sim --> G([Retorna valor])
```

## 3. Cadastrar produto

```mermaid
flowchart TD
    A([Início]) --> B{"total_produtos >= MAX ?"}
    B -- Sim --> X[/"Limite atingido"/] --> Z([Fim])
    B -- Não --> C[/"Ler nome (não vazio, até 40 letras)"/]
    C --> D{"Nome já existe?<br/>(ignora maiúsc./minúsc.)"}
    D -- Sim --> Y[/"Produto já existe, use Editar"/] --> Z
    D -- Não --> E[/"Ler unidade (menu), quantidade,<br/>preço de custo e estoque mínimo"/]
    E --> F["Guardar nos vetores na posição total_produtos"]
    F --> G["total_produtos = total_produtos + 1"]
    G --> H[/"Produto cadastrado!"/] --> Z
```

## 4. Registrar entrada (compra)

```mermaid
flowchart TD
    A([Início]) --> B{"Há produtos?"}
    B -- Não --> X[/"Nenhum produto cadastrado"/] --> Z([Fim])
    B -- Sim --> C{"Histórico cheio?"}
    C -- Sim --> Y[/"Histórico cheio"/] --> Z
    C -- Não --> D[/"Escolher produto i pelo número"/]
    D --> E[/"Ler quantidade > 0"/]
    E --> F{"estoque + qtd > limite?"}
    F -- Sim --> W[/"Entrada recusada"/] --> Z
    F -- Não --> G["quantidades[i] = quantidades[i] + qtd"]
    G --> H["Guardar movimento ENTRADA no histórico"]
    H --> I[/"Mostrar novo estoque"/] --> Z
```

## 5. Registrar saída (uso/venda)

```mermaid
flowchart TD
    A([Início]) --> B{"Há produtos?"}
    B -- Não --> X[/"Nenhum produto cadastrado"/] --> Z([Fim])
    B -- Sim --> C{"Histórico cheio?"}
    C -- Sim --> Y[/"Histórico cheio"/] --> Z
    C -- Não --> D[/"Escolher produto i pelo número"/]
    D --> E[/"Ler quantidade > 0"/]
    E --> F{"qtd > quantidades[i] ?"}
    F -- Sim --> W[/"Saída recusada: estoque insuficiente"/] --> Z
    F -- Não --> G["quantidades[i] = quantidades[i] - qtd"]
    G --> H["Guardar movimento SAIDA no histórico"]
    H --> I{"quantidades[i] <= minimos[i] ?"}
    I -- Sim --> J[/"ALERTA: estoque baixo"/] --> Z
    I -- Não --> K[/"Saída registrada"/] --> Z
```

## 6. Relatório com impostos

```mermaid
flowchart TD
    A([Início]) --> B{"Há produtos?"}
    B -- Não --> X[/"Nenhum produto cadastrado"/] --> Z([Fim])
    B -- Sim --> C["total_estoque = 0, total_impostos = 0, i = 0"]
    C --> D{"i < total_produtos ?"}
    D -- Sim --> E["icms = arredondar(preço x 18%)<br/>pis = arredondar(preço x 1,65%)<br/>cofins = arredondar(preço x 7,6%)"]
    E --> F["custo_real = preço + icms + pis + cofins<br/>valor = arredondar(custo_real x quantidade)"]
    F --> G["Somar nos totais"]
    G --> H[/"Mostrar linha do produto"/]
    H --> I{"quantidade <= mínimo ?"}
    I -- Sim --> J[/"SITUAÇÃO: ESTOQUE BAIXO"/] --> K["i = i + 1"]
    I -- Não --> L[/"SITUAÇÃO: OK"/] --> K
    K --> D
    D -- Não --> M[/"Mostrar valor total do estoque,<br/>total de impostos e nº de produtos em alerta"/] --> Z
```
