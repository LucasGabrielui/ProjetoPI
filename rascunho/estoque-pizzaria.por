programa
{
	// RASCUNHO (feito pela IA) - NAO ENTREGAR. Use so para estudar e reescrever.
	// Sistema de estoque tributavel da pizzaria - versao em portugol (Portugol Studio)

	inclua biblioteca Texto --> tx
	inclua biblioteca Tipos --> tp
	inclua biblioteca Matematica --> mt

	// ---------- Constantes ----------
	const inteiro MAX_PRODUTOS = 50
	const inteiro MAX_MOVIMENTOS = 500
	const inteiro MAX_LETRAS_NOME = 40
	const real VALOR_MAXIMO = 100000.0
	const real ICMS = 0.18
	const real PIS = 0.0165
	const real COFINS = 0.076

	// ---------- Produtos (vetores paralelos: a posicao i e o mesmo produto em todos) ----------
	cadeia nomes[MAX_PRODUTOS]
	cadeia unidades[MAX_PRODUTOS]
	real quantidades[MAX_PRODUTOS]
	real precos[MAX_PRODUTOS]
	real minimos[MAX_PRODUTOS]
	inteiro total_produtos = 0

	// ---------- Historico de movimentacoes ----------
	inteiro mov_produto[MAX_MOVIMENTOS]
	cadeia mov_tipo[MAX_MOVIMENTOS]
	real mov_quantidade[MAX_MOVIMENTOS]
	real mov_saldo[MAX_MOVIMENTOS]
	inteiro total_movimentos = 0

	funcao inicio()
	{
		inteiro opcao = -1

		enquanto (opcao != 0)
		{
			mostrar_painel()
			opcao = ler_inteiro("Escolha uma opcao: ", 0, 7)

			escolha (opcao)
			{
				caso 1:
					cadastrar_produto()
					pare
				caso 2:
					listar_produtos()
					pare
				caso 3:
					editar_produto()
					pare
				caso 4:
					registrar_entrada()
					pare
				caso 5:
					registrar_saida()
					pare
				caso 6:
					mostrar_relatorio()
					pare
				caso 7:
					mostrar_historico()
					pare
				caso 0:
					escreva("\nSistema encerrado. Ate logo!\n")
					pare
				caso contrario:
					escreva("Opcao invalida.\n")
			}
		}
	}

	// ================= TELAS =================

	funcao mostrar_painel()
	{
		inteiro baixos = contar_estoque_baixo()

		escreva("\n========== PIZZARIA - ESTOQUE ==========\n")
		escreva("Produtos cadastrados: ", total_produtos, " de ", MAX_PRODUTOS, "\n")
		escreva("Movimentacoes registradas: ", total_movimentos, "\n")
		se (baixos > 0)
		{
			escreva("ATENCAO: ", baixos, " produto(s) com estoque baixo!\n")
		}
		escreva("----------------------------------------\n")
		escreva("1 - Cadastrar produto\n")
		escreva("2 - Listar produtos\n")
		escreva("3 - Editar produto\n")
		escreva("4 - Registrar entrada (compra)\n")
		escreva("5 - Registrar saida (uso/venda)\n")
		escreva("6 - Relatorio do estoque e impostos\n")
		escreva("7 - Historico de movimentacoes\n")
		escreva("0 - Sair\n")
	}

	funcao cadastrar_produto()
	{
		escreva("\n--- CADASTRAR PRODUTO ---\n")

		se (total_produtos >= MAX_PRODUTOS)
		{
			escreva("Limite de ", MAX_PRODUTOS, " produtos atingido. Nao e possivel cadastrar.\n")
		}
		senao
		{
			cadeia nome = ler_texto_obrigatorio("Nome do produto: ")

			se (buscar_produto(nome) != -1)
			{
				escreva("Ja existe um produto com o nome ", nome, ". Use a opcao 3 para editar.\n")
			}
			senao
			{
				cadeia unidade = ler_unidade()
				real quantidade = ler_real("Quantidade atual em estoque: ", 0.0, VALOR_MAXIMO)
				real preco = ler_real("Preco de custo por " + unidade + " (R$): ", 0.01, VALOR_MAXIMO)
				real minimo = ler_real("Estoque minimo (alerta): ", 0.0, VALOR_MAXIMO)

				nomes[total_produtos] = nome
				unidades[total_produtos] = unidade
				quantidades[total_produtos] = mt.arredondar(quantidade, 3)
				precos[total_produtos] = mt.arredondar(preco, 2)
				minimos[total_produtos] = mt.arredondar(minimo, 3)
				total_produtos++

				escreva("Produto cadastrado com sucesso!\n")
			}
		}
	}

	funcao listar_produtos()
	{
		escreva("\n--- LISTA DE PRODUTOS ---\n")

		se (total_produtos == 0)
		{
			escreva("Nenhum produto cadastrado ainda. Use a opcao 1.\n")
		}
		senao
		{
			para (inteiro i = 0; i < total_produtos; i++)
			{
				escreva(i + 1, ") ", nomes[i], " | ", quantidades[i], " ", unidades[i])
				escreva(" | custo R$ ", precos[i], " | minimo ", minimos[i])
				se (estoque_baixo(i))
				{
					escreva("  << ESTOQUE BAIXO")
				}
				escreva("\n")
			}
		}
	}

	funcao editar_produto()
	{
		escreva("\n--- EDITAR PRODUTO ---\n")

		se (total_produtos == 0)
		{
			escreva("Nenhum produto cadastrado ainda. Use a opcao 1.\n")
		}
		senao
		{
			inteiro i = escolher_produto()

			escreva("Editando: ", nomes[i], " (", unidades[i], ")\n")
			cadeia novo_nome = ler_texto_obrigatorio("Novo nome: ")
			inteiro outro = buscar_produto(novo_nome)

			se (outro != -1 e outro != i)
			{
				escreva("Ja existe outro produto com esse nome. Nada foi alterado.\n")
			}
			senao
			{
				nomes[i] = novo_nome
				precos[i] = mt.arredondar(ler_real("Novo preco de custo (R$): ", 0.01, VALOR_MAXIMO), 2)
				minimos[i] = mt.arredondar(ler_real("Novo estoque minimo: ", 0.0, VALOR_MAXIMO), 3)
				escreva("Produto atualizado!\n")
			}
		}
	}

	funcao registrar_entrada()
	{
		escreva("\n--- ENTRADA DE ESTOQUE (COMPRA) ---\n")

		se (total_produtos == 0)
		{
			escreva("Nenhum produto cadastrado ainda. Use a opcao 1.\n")
		}
		senao se (total_movimentos >= MAX_MOVIMENTOS)
		{
			escreva("Historico cheio. Nao e possivel registrar novas movimentacoes.\n")
		}
		senao
		{
			inteiro i = escolher_produto()
			real qtd = ler_real("Quantidade que entrou (" + unidades[i] + "): ", 0.001, VALOR_MAXIMO)

			se (quantidades[i] + qtd > VALOR_MAXIMO)
			{
				escreva("Entrada recusada: o estoque passaria do limite de ", VALOR_MAXIMO, ".\n")
			}
			senao
			{
				quantidades[i] = mt.arredondar(quantidades[i] + qtd, 3)
				guardar_movimento(i, "ENTRADA", qtd)
				escreva("Entrada registrada. Estoque de ", nomes[i], ": ", quantidades[i], " ", unidades[i], "\n")
			}
		}
	}

	funcao registrar_saida()
	{
		escreva("\n--- SAIDA DE ESTOQUE (USO/VENDA) ---\n")

		se (total_produtos == 0)
		{
			escreva("Nenhum produto cadastrado ainda. Use a opcao 1.\n")
		}
		senao se (total_movimentos >= MAX_MOVIMENTOS)
		{
			escreva("Historico cheio. Nao e possivel registrar novas movimentacoes.\n")
		}
		senao
		{
			inteiro i = escolher_produto()
			real qtd = ler_real("Quantidade que saiu (" + unidades[i] + "): ", 0.001, VALOR_MAXIMO)

			se (qtd > quantidades[i])
			{
				escreva("Saida recusada: so existem ", quantidades[i], " ", unidades[i], " de ", nomes[i], ".\n")
			}
			senao
			{
				quantidades[i] = mt.arredondar(quantidades[i] - qtd, 3)
				guardar_movimento(i, "SAIDA", qtd)
				escreva("Saida registrada. Estoque de ", nomes[i], ": ", quantidades[i], " ", unidades[i], "\n")
				se (estoque_baixo(i))
				{
					escreva("ATENCAO: ", nomes[i], " esta com estoque baixo! Hora de comprar.\n")
				}
			}
		}
	}

	funcao mostrar_relatorio()
	{
		escreva("\n--- RELATORIO DO ESTOQUE ---\n")
		escreva("Impostos: ICMS ", ICMS * 100, "% | PIS ", PIS * 100, "% | COFINS ", COFINS * 100, "%\n")

		se (total_produtos == 0)
		{
			escreva("Nenhum produto cadastrado ainda. Use a opcao 1.\n")
		}
		senao
		{
			real total_estoque = 0.0
			real total_impostos = 0.0
			inteiro baixos = 0

			para (inteiro i = 0; i < total_produtos; i++)
			{
				real icms = calcular_imposto(precos[i], ICMS)
				real pis = calcular_imposto(precos[i], PIS)
				real cofins = calcular_imposto(precos[i], COFINS)
				real impostos = icms + pis + cofins
				real custo_real = precos[i] + impostos
				real valor_em_estoque = mt.arredondar(custo_real * quantidades[i], 2)

				total_estoque = total_estoque + valor_em_estoque
				total_impostos = total_impostos + mt.arredondar(impostos * quantidades[i], 2)

				escreva("\n", i + 1, ") ", nomes[i], " - ", quantidades[i], " ", unidades[i], "\n")
				escreva("   Preco de custo: R$ ", precos[i], " por ", unidades[i], "\n")
				escreva("   ICMS: R$ ", icms, " | PIS: R$ ", pis, " | COFINS: R$ ", cofins, "\n")
				escreva("   Custo real (preco + impostos): R$ ", mt.arredondar(custo_real, 2), " por ", unidades[i], "\n")
				escreva("   Valor em estoque: R$ ", valor_em_estoque, "\n")
				se (estoque_baixo(i))
				{
					escreva("   SITUACAO: ESTOQUE BAIXO (minimo ", minimos[i], ")\n")
					baixos++
				}
				senao
				{
					escreva("   SITUACAO: OK\n")
				}
			}

			escreva("\n========================================\n")
			escreva("Valor total do estoque (custo real): R$ ", mt.arredondar(total_estoque, 2), "\n")
			escreva("Total de impostos no estoque: R$ ", mt.arredondar(total_impostos, 2), "\n")
			escreva("Produtos com estoque baixo: ", baixos, "\n")
		}
	}

	funcao mostrar_historico()
	{
		escreva("\n--- HISTORICO DE MOVIMENTACOES ---\n")

		se (total_movimentos == 0)
		{
			escreva("Nenhuma movimentacao registrada ainda.\n")
		}
		senao
		{
			para (inteiro m = 0; m < total_movimentos; m++)
			{
				inteiro p = mov_produto[m]
				escreva(m + 1, ") ", mov_tipo[m], " | ", nomes[p], " | ", mov_quantidade[m], " ", unidades[p])
				escreva(" | saldo depois: ", mov_saldo[m], " ", unidades[p], "\n")
			}
		}
	}

	// ================= REGRAS DO ESTOQUE =================

	// Imposto de UM produto, ja arredondado em centavos
	funcao real calcular_imposto(real preco, real aliquota)
	{
		retorne mt.arredondar(preco * aliquota, 2)
	}

	funcao logico estoque_baixo(inteiro i)
	{
		retorne quantidades[i] <= minimos[i]
	}

	funcao inteiro contar_estoque_baixo()
	{
		inteiro contador = 0
		para (inteiro i = 0; i < total_produtos; i++)
		{
			se (estoque_baixo(i))
			{
				contador++
			}
		}
		retorne contador
	}

	// Devolve a posicao do produto com esse nome, ou -1 se nao existir.
	// Compara em maiusculas para "Queijo" e "QUEIJO" serem o mesmo produto.
	funcao inteiro buscar_produto(cadeia nome)
	{
		inteiro posicao = -1
		para (inteiro i = 0; i < total_produtos; i++)
		{
			se (tx.caixa_alta(nomes[i]) == tx.caixa_alta(nome))
			{
				posicao = i
			}
		}
		retorne posicao
	}

	funcao guardar_movimento(inteiro i, cadeia tipo, real qtd)
	{
		mov_produto[total_movimentos] = i
		mov_tipo[total_movimentos] = tipo
		mov_quantidade[total_movimentos] = qtd
		mov_saldo[total_movimentos] = quantidades[i]
		total_movimentos++
	}

	// ================= LEITURA SEGURA (nunca trava) =================

	// Mostra a lista e devolve a POSICAO (0, 1, 2...) do produto escolhido
	funcao inteiro escolher_produto()
	{
		para (inteiro i = 0; i < total_produtos; i++)
		{
			escreva(i + 1, ") ", nomes[i], " (", quantidades[i], " ", unidades[i], ")\n")
		}
		inteiro numero = ler_inteiro("Numero do produto: ", 1, total_produtos)
		retorne numero - 1
	}

	funcao cadeia ler_unidade()
	{
		cadeia unidade = "un"
		escreva("Unidades: 1-kg  2-g  3-L  4-ml  5-un\n")
		inteiro opcao = ler_inteiro("Escolha a unidade: ", 1, 5)

		escolha (opcao)
		{
			caso 1:
				unidade = "kg"
				pare
			caso 2:
				unidade = "g"
				pare
			caso 3:
				unidade = "L"
				pare
			caso 4:
				unidade = "ml"
				pare
			caso contrario:
				unidade = "un"
		}
		retorne unidade
	}

	funcao cadeia ler_texto_obrigatorio(cadeia mensagem)
	{
		cadeia texto = ""
		logico valido = falso

		faca
		{
			escreva(mensagem)
			leia(texto)

			se (so_espacos(texto))
			{
				escreva("Este campo nao pode ficar vazio.\n")
			}
			senao se (tx.numero_caracteres(texto) > MAX_LETRAS_NOME)
			{
				escreva("Use no maximo ", MAX_LETRAS_NOME, " letras.\n")
			}
			senao
			{
				valido = verdadeiro
			}
		}
		enquanto (nao valido)

		retorne texto
	}

	// Verdadeiro se o texto estiver vazio ou tiver so espacos
	funcao logico so_espacos(cadeia texto)
	{
		logico resposta = verdadeiro
		para (inteiro i = 0; i < tx.numero_caracteres(texto); i++)
		{
			se (tx.obter_caracter(texto, i) != ' ')
			{
				resposta = falso
			}
		}
		retorne resposta
	}

	funcao inteiro ler_inteiro(cadeia mensagem, inteiro minimo, inteiro maximo)
	{
		cadeia texto = ""
		inteiro valor = 0
		logico valido = falso

		faca
		{
			escreva(mensagem)
			leia(texto)

			se (tp.cadeia_e_inteiro(texto, 10))
			{
				valor = tp.cadeia_para_inteiro(texto, 10)
				se (valor >= minimo e valor <= maximo)
				{
					valido = verdadeiro
				}
			}

			se (nao valido)
			{
				escreva("Valor invalido. Digite um numero inteiro de ", minimo, " ate ", maximo, ".\n")
			}
		}
		enquanto (nao valido)

		retorne valor
	}

	// Aceita "12,50" ou "12.50". Recusa letras, vazio e numeros fora do limite.
	funcao real ler_real(cadeia mensagem, real minimo, real maximo)
	{
		cadeia texto = ""
		real valor = 0.0
		logico valido = falso

		faca
		{
			escreva(mensagem)
			leia(texto)
			texto = tx.substituir(texto, ",", ".")

			se (tp.cadeia_e_inteiro(texto, 10))
			{
				valor = tp.inteiro_para_real(tp.cadeia_para_inteiro(texto, 10))
				valido = verdadeiro
			}
			senao se (tp.cadeia_e_real(texto))
			{
				valor = tp.cadeia_para_real(texto)
				valido = verdadeiro
			}

			// Escrito "dentro do limite" (e nao "fora do limite") de proposito:
			// assim um valor estranho como "NaN" tambem e recusado.
			se (valido)
			{
				valido = (valor >= minimo e valor <= maximo)
			}

			se (nao valido)
			{
				escreva("Valor invalido. Digite um numero de ", minimo, " ate ", maximo, " (ex.: 12,50).\n")
			}
		}
		enquanto (nao valido)

		retorne valor
	}
}
