# Explicação do portugol (rascunho da IA), parte por parte

Arquivo explicado: `rascunho/estoque-pizzaria.por` (Portugol Studio).
Leia com o código aberto do lado. Depois **feche os dois** e escreva a sua versão.

---

## 0. A ideia geral em 4 frases

1. O sistema guarda os produtos em **vetores paralelos**: `nomes[3]`, `quantidades[3]`, `precos[3]`... a posição 3 de todos os vetores é **o mesmo produto**.
2. Um **menu dentro de um `enquanto`** repete até a pessoa digitar 0.
3. Cada opção do menu chama uma **função** (cadastrar, entrada, saída, relatório...).
4. Todo número digitado passa por uma **leitura segura**, que repete a pergunta até o valor ser válido. Por isso o sistema não trava.

---

## 1. Bibliotecas (linhas `inclua biblioteca ...`)

```
inclua biblioteca Texto --> tx
inclua biblioteca Tipos --> tp
inclua biblioteca Matematica --> mt
```
São "caixas de ferramentas" que já vêm no Portugol Studio. O `--> tx` é um apelido: escrevo `tx.caixa_alta(...)` em vez de `Texto.caixa_alta(...)`.

| Biblioteca | Para que eu usei |
|---|---|
| `Texto` (tx) | `caixa_alta` (comparar nomes sem diferença de maiúscula), `numero_caracteres` (tamanho do nome), `substituir` (trocar vírgula por ponto), `obter_caracter` (pegar uma letra do texto) |
| `Tipos` (tp) | `cadeia_e_inteiro` / `cadeia_e_real` (o texto digitado é um número?) e `cadeia_para_...` (converter texto em número) |
| `Matematica` (mt) | `arredondar(valor, 2)`: arredondar dinheiro em centavos |

> ⚠️ **Se o professor não ensinou bibliotecas**, me avise. Dá para trocar a leitura segura por `leia(numero)` simples. A lógica do estoque continua igual, só perde a proteção contra letras no portugol (no Java a gente protege de outro jeito).

---

## 2. Constantes (`const`)

```
const inteiro MAX_PRODUTOS = 50
const inteiro MAX_MOVIMENTOS = 500
const inteiro MAX_LETRAS_NOME = 40
const real VALOR_MAXIMO = 100000.0
const real ICMS = 0.18
const real PIS = 0.0165
const real COFINS = 0.076
```
- `const` = valor que **nunca muda** durante o programa. Por convenção o nome fica em MAIÚSCULAS.
- `MAX_PRODUTOS`: tamanho dos vetores. Vetor tem tamanho fixo, então preciso de um limite.
- `VALOR_MAXIMO`: trava contra "valores gigantes" (ninguém compra 1 bilhão de kg de queijo).
- Impostos escritos em decimal: 18% = 18/100 = **0.18**; 1,65% = **0.0165**; 7,6% = **0.076**.
- Por que constante? Se a alíquota mudar, troco em **um lugar só**.

---

## 3. Variáveis globais (os vetores)

```
cadeia nomes[MAX_PRODUTOS]
cadeia unidades[MAX_PRODUTOS]
real quantidades[MAX_PRODUTOS]
real precos[MAX_PRODUTOS]
real minimos[MAX_PRODUTOS]
inteiro total_produtos = 0
```
- Ficam **fora** das funções, então **todas** as funções enxergam (variável global).
- `real` em quantidade, porque dá para ter 2,5 kg de farinha.
- `total_produtos` faz dois papéis: diz **quantos** produtos existem e também **qual é a próxima posição livre**. Com 3 produtos (posições 0, 1, 2), o próximo vai na posição 3 = `total_produtos`.

Histórico, também com vetores paralelos:
```
inteiro mov_produto[MAX_MOVIMENTOS]   // posição do produto que mexeu
cadeia  mov_tipo[MAX_MOVIMENTOS]      // "ENTRADA" ou "SAIDA"
real    mov_quantidade[MAX_MOVIMENTOS]// quanto entrou/saiu
real    mov_saldo[MAX_MOVIMENTOS]     // quanto ficou depois
inteiro total_movimentos = 0
```
Guardo a **posição** do produto (`mov_produto`) e não o nome. Assim, se o nome for editado, o histórico mostra o nome novo e continua certo.

---

## 4. `funcao inicio()`: o menu

```
inteiro opcao = -1
enquanto (opcao != 0)
{
    mostrar_painel()
    opcao = ler_inteiro("Escolha uma opcao: ", 0, 7)
    escolha (opcao) { caso 1: cadastrar_produto() pare ... }
}
```
- `opcao` começa em **-1** só para entrar no `enquanto` na primeira vez (-1 é diferente de 0).
- `ler_inteiro(..., 0, 7)` **só devolve** um número de 0 a 7. Letra ou 99 não passam.
- `escolha/caso` é o `switch`. O `pare` impede que ele "caia" no próximo caso.
- `caso contrario` nunca deveria acontecer, porque `ler_inteiro` já garante 0 a 7. Está ali como segurança extra (programação defensiva).
- Digitou 0? Mostra "Sistema encerrado", volta para o `enquanto`, a condição `0 != 0` é falsa e o programa termina.

---

## 5. `mostrar_painel()`: o "painel" do site, em versão texto

Conta os produtos com estoque baixo (`contar_estoque_baixo()`) e, se tiver algum, mostra o **ATENÇÃO** logo em cima do menu. No site essa tela vai ser a página inicial (painel).

---

## 6. `cadastrar_produto()`

Ordem das verificações (é isso que o professor quer ver):
1. **Tem espaço?** `se (total_produtos >= MAX_PRODUTOS)`. Sem isso, escrever em `nomes[50]` dá erro e o programa para.
2. **Lê o nome** com `ler_texto_obrigatorio` (não aceita vazio nem só espaços, e aceita no máximo 40 letras).
3. **Nome repetido?** `se (buscar_produto(nome) != -1)`. `buscar_produto` devolve -1 quando **não** acha.
4. Lê unidade (menu de 1 a 5, então ninguém digita "quilo", "KG", "Kg"...), quantidade (pode ser 0), preço (mínimo R$ 0,01) e estoque mínimo.
5. Guarda tudo **na mesma posição** `total_produtos` de cada vetor e faz `total_produtos++`.

`mt.arredondar(preco, 2)`: se digitarem 10,999, fica 11,00. Dinheiro sempre com 2 casas.
`mt.arredondar(quantidade, 3)`: quantidade com até 3 casas (1,250 kg = 1 kg e 250 g).

> A quantidade digitada no cadastro é o que **já existe na prateleira** no dia em que o sistema começa a ser usado. Depois disso, quantidade **só muda por entrada ou saída**, que ficam no histórico. Por isso **Editar não deixa mudar a quantidade**: se deixasse, o estoque mudaria sem registro, e isso é ruim para controle e para auditoria fiscal.

---

## 7. `listar_produtos()`

Um `para` de `0` até `total_produtos - 1`. Mostra `i + 1` porque, para o usuário, o primeiro produto é o "1", não o "0".

---

## 8. `editar_produto()`

- Escolhe o produto **pelo número** da lista (`escolher_produto()`). Assim "produto que não existe" fica impossível: o número tem que estar entre 1 e o total.
- Novo nome: confere se existe **outro** produto com esse nome: `se (outro != -1 e outro != i)`.
  - `outro != i` existe para deixar a pessoa manter o mesmo nome (ou só trocar maiúscula/minúscula).
- **Unidade e quantidade não são editáveis.** Trocar "kg" por "g" faria 5 kg virar 5 g.

---

## 9. `registrar_entrada()` e `registrar_saida()`, o coração do estoque

As duas têm a mesma estrutura:
```
se (não tem produto)      -> avisa
senao se (histórico cheio) -> avisa
senao
    escolhe produto i
    lê quantidade (mínimo 0.001: zero e negativo são recusados)
    se (regra quebrada) -> recusa
    senao -> atualiza quantidades[i], guarda movimento, mostra novo saldo
```
- **Regra da entrada:** o estoque não pode passar de `VALOR_MAXIMO`.
- **Regra da saída:** `se (qtd > quantidades[i])`, então a saída é recusada. **Estoque nunca fica negativo.**
- Depois da saída, se `estoque_baixo(i)`, mostra o alerta na hora.
- Por que conferir o histórico cheio **antes** de mexer no estoque? Para não acontecer de o estoque mudar e o histórico não registrar.

`mt.arredondar(quantidades[i] - qtd, 3)`: o computador faz conta com real de um jeito "torto" (0,1 + 0,2 dá 0,30000000000000004). O arredondamento limpa isso.

---

## 10. `mostrar_relatorio()`, os impostos

Para **cada produto**:
```
icms   = arredondar(preço x 0.18,   2)
pis    = arredondar(preço x 0.0165, 2)
cofins = arredondar(preço x 0.076,  2)
custo_real = preço + icms + pis + cofins
valor_em_estoque = arredondar(custo_real x quantidade, 2)
```
E no fim mostra os totais.

### Conta na mão (já conferida no computador)

| Produto | Preço | ICMS 18% | PIS 1,65% | COFINS 7,6% | Impostos | Custo real | Qtd | Valor em estoque |
|---|---|---|---|---|---|---|---|---|
| Muçarela (kg) | 32,90 | 5,922 → **5,92** | 0,54285 → **0,54** | 2,5004 → **2,50** | 8,96 | **41,86** | 10 | **418,60** |
| Farinha (kg) | 5,50 | 0,99 → **0,99** | 0,09075 → **0,09** | 0,418 → **0,42** | 1,50 | **7,00** | 25 | **175,00** |
| Molho (un) | 8,00 | 1,44 → **1,44** | 0,132 → **0,13** | 0,608 → **0,61** | 2,18 | **10,18** | 12 | **122,16** |

Total do estoque: 418,60 + 175,00 + 122,16 = **R$ 715,76**.

### ⚠️ Pegadinha do arredondamento (prepare essa resposta!)

Preço R$ 10,00:
- **Arredondando cada imposto** (como o sistema faz): 1,80 + 0,17 + 0,76 = 2,73, então o custo real é **R$ 12,73**.
- **Arredondando só no final**: 1,80 + 0,165 + 0,76 = 2,725, então o custo real é 12,725, que arredonda para **R$ 12,74**.

Escolhi **arredondar cada imposto** porque numa nota fiscal cada imposto aparece separado, em centavos, e a soma da tabela tem que fechar. O importante é **ser sempre do mesmo jeito**, no portugol e no Java.

> Simplificação: os impostos são calculados "por fora" (preço × porcentagem), com porcentagens fixas. No mundo real o ICMS é "por dentro" e muda por estado e produto. Vale falar isso na apresentação como **limitação conhecida**.

---

## 11. `mostrar_historico()`

Percorre os movimentos. `inteiro p = mov_produto[m]` pega a posição do produto, e com ela busco `nomes[p]` e `unidades[p]`.

---

## 12. Funções de regra

- `calcular_imposto(preco, aliquota)`: **uma** fórmula para os três impostos. Evita repetir conta.
- `estoque_baixo(i)`: devolve `verdadeiro` se `quantidade <= mínimo`. Usei `<=` porque, chegando **no** mínimo, já é hora de comprar.
- `contar_estoque_baixo()`: o padrão **contador** (`contador++` dentro do `para`).
- `buscar_produto(nome)`: o padrão **busca**. Começa com `posicao = -1` ("não achei") e, se achar, guarda a posição. Compara com `tx.caixa_alta` dos dois lados, então "queijo" e "QUEIJO" contam como o mesmo nome.
- `guardar_movimento(i, tipo, qtd)`: grava nas posições `total_movimentos` dos 4 vetores do histórico e soma 1. É a mesma ideia do cadastro.

---

## 13. Leitura segura (o motivo de o sistema não travar)

### `ler_inteiro(mensagem, minimo, maximo)`
```
faca
    escreva mensagem; leia TEXTO
    se texto é inteiro -> converte; se está entre minimo e maximo -> valido
    se nao valido -> mostra erro
enquanto (nao valido)
```
- Lê como **texto** (`cadeia`), não como número. Se lesse direto em `inteiro`, digitar "abc" daria erro.
- `faca ... enquanto` (do-while): pergunta **pelo menos uma vez** e repete enquanto estiver errado.

### `ler_real(...)`
Igual ao `ler_inteiro`, mais 2 detalhes:
- `tx.substituir(texto, ",", ".")`: o brasileiro digita **12,50**, e o computador entende **12.50**.
- Primeiro testa se é inteiro ("10"), depois se é real ("10.5").
- A conferência é `valido = (valor >= minimo e valor <= maximo)`, escrita como "**está dentro**" do limite. Se fosse escrita "está fora" (`valor < minimo ou valor > maximo`), um texto esquisito como `NaN` ("não é número") passaria, porque **qualquer comparação com NaN dá falso**. Conferi isso no Java.

### `ler_texto_obrigatorio` e `so_espacos`
- `so_espacos` percorre letra por letra. Se achar **alguma** letra que não é espaço, o texto não é vazio.
- Isso impede cadastrar um produto chamado "     ".

---

## 14. O que esta versão já aguenta (teste de "ataque")

| Ataque | O que acontece |
|---|---|
| Letra onde é número | "Valor inválido", pergunta de novo |
| Campo vazio | Pergunta de novo |
| Negativo / zero na entrada ou saída | Recusado (mínimo 0,001) |
| Decimal com vírgula `12,5` | Aceito como 12.5 |
| Valor gigante `99999999` | Recusado (máximo 100000) |
| Saída maior que o estoque | "Saída recusada" e o estoque não muda |
| Produto que não existe | Impossível: escolhe pelo número de 1 até o total |
| Nome duplicado (até "QUEIJO" × "queijo") | Recusado |
| Nome só com espaços | Recusado |
| 51º produto / histórico cheio | Mensagem, sem erro |
| Opção 9 no menu | "Valor inválido" |

O que **ainda não** dá para testar no portugol e vai ficar para o Java/site: HTML/script no nome, acesso pela URL, recarregar a página e cliques repetidos.
