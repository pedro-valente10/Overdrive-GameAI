extends Node2D

var rank_corredores: Array = []

@onready var painel_final = $"../CanvasLayer/PainelFinal"
@onready var label_resultado = $"../CanvasLayer/PainelFinal/ResultadoLabel"

func _process(_delta):
	atualizar_posicoes()

func atualizar_posicoes():
	var todos_corredores = get_tree().get_nodes_in_group("corredores")
	todos_corredores.sort_custom(_ordenar_por_progresso)
	rank_corredores = todos_corredores

func _ordenar_por_progresso(a, b):
	if a.has_method("obter_pontuacao_corrida") and b.has_method("obter_pontuacao_corrida"):
		return a.obter_pontuacao_corrida() > b.obter_pontuacao_corrida()
	return false
	
func finalizar_corrida(vencedor):
	var jogador_node = null
	for corredor in rank_corredores:
		if corredor.name == "CharacterBody2D" or not ("Bot" in corredor.name):
			jogador_node = corredor
			break
	
	var posicao_final = rank_corredores.find(jogador_node) + 1 
	
	if vencedor == jogador_node:
		label_resultado.text = "VITÓRIA!\nVocê terminou em 1º"
		label_resultado.modulate = Color.GREEN
	else:
		label_resultado.text = "DERROTA!\nVocê terminou em " + str(posicao_final) + "º lugar"
		label_resultado.modulate = Color.RED
	
	if painel_final:
		painel_final.show()
	label_resultado.show()

	get_tree().paused = true
