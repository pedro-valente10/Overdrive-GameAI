extends Node2D

var rank_corredores: Array = []

# Pegamos a referência do Painel inteiro também para podermos exibi-lo
@onready var painel_final = $"../CanvasLayer/PainelFinal"
@onready var label_resultado = $"../CanvasLayer/PainelFinal/ResultadoLabel"

func _process(_delta):
	atualizar_posicoes()

func atualizar_posicoes():
	var todos_corredores = get_tree().get_nodes_in_group("corredores")
	
	# Ordena a lista usando a função personalizada
	todos_corredores.sort_custom(_ordenar_por_progresso)
	rank_corredores = todos_corredores

func _ordenar_por_progresso(a, b):
	# Proteção: Garante que ambos os nós têm a função de pontuação antes de comparar
	if a.has_method("obter_pontuacao_corrida") and b.has_method("obter_pontuacao_corrida"):
		return a.obter_pontuacao_corrida() > b.obter_pontuacao_corrida()
	return false
	
# AQUI ESTÁ A FUNÇÃO COM O NOME CORRETO QUE O MAPA ESTÁ PROCURANDO
func finalizar_corrida(vencedor):
	# Descobre quem é o jogador humano na lista para saber a posição dele
	var jogador_node = null
	for corredor in rank_corredores:
		# Verifica se é o nó do jogador (geralmente chamado de CharacterBody2D)
		if corredor.name == "CharacterBody2D" or not ("Bot" in corredor.name):
			jogador_node = corredor
			break
	
	# Encontra a posição final do jogador (somamos 1 porque arrays começam em 0)
	var posicao_final = rank_corredores.find(jogador_node) + 1 
	
	# Se quem cruzou a linha de chegada das 5 voltas foi o próprio jogador
	if vencedor == jogador_node:
		label_resultado.text = "VITÓRIA! Você chegou em 1º!"
		label_resultado.modulate = Color.GREEN
	else:
		label_resultado.text = "DERROTA! Você terminou em " + str(posicao_final) + "º lugar."
		label_resultado.modulate = Color.RED
	
	# Torna o Painel Final E o Texto visíveis na tela
	if painel_final:
		painel_final.show()
	label_resultado.show()
	
	# Pausa o jogo para ninguém se mexer mais
	get_tree().paused = true
