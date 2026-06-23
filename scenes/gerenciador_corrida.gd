extends Node2D

var rank_corredores: Array = []
# 1. CRIAMOS UMA TRAVA: Controla se a corrida já acabou
var corrida_finalizada: bool = false 

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
	# 1. VERIFICAÇÃO DA TRAVA: Se a corrida já acabou, ignora as próximas chamadas
	if corrida_finalizada:
		return
	corrida_finalizada = true
	
	# Desativa o _process para poupar desempenho
	set_process(false)
	
	atualizar_posicoes()
	
	var jogador_node = null
	for corredor in rank_corredores:
		if corredor.name == "CharacterBody2D" or not ("Bot" in corredor.name):
			jogador_node = corredor
			break
	
	# Cálculo inicial baseado no progresso físico do frame
	var posicao_final_calculada = rank_corredores.find(jogador_node) + 1 
	 
	# --- CORREÇÃO ABSOLUTA DE RANKING ---
	# Se a linha de chegada avisou que o jogador cruzou primeiro, ele é 1º obrigatoriamente,
	# mesmo que o reset de checkpoints tenha bagunçado o sort_custom neste frame.
	if vencedor == jogador_node:
		posicao_final_calculada = 1
	else:
		# Se o jogador NÃO venceu, mas o cálculo de progresso achou que ele estava em 1º,
		# nós o jogamos para 2º (já que um bot cruzou a linha antes dele).
		if posicao_final_calculada == 1:
			posicao_final_calculada = 2
	# -------------------------------------
	
	# Salva os dados no Autoload/Singleton global
	DadosCorrida.jogador_venceu = (vencedor == jogador_node)
	DadosCorrida.posicao_final = posicao_final_calculada
	
	print("Corrida finalizada! Jogador terminou na posição: ", DadosCorrida.posicao_final)
	
	fazer_fade_out_e_mudar_cena()

func fazer_fade_out_e_mudar_cena():
	var tela_preta = ColorRect.new()
	tela_preta.color = Color.BLACK
	tela_preta.modulate.a = 0.0
	tela_preta.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# 1. ADIÇÃO SEGURA: Só adiciona o nó após a física terminar de processar
	$"../CanvasLayer".call_deferred("add_child", tela_preta)
	
	# 2. ESPERA ESTRATÉGICA: Aguarda um frame para a tela_preta realmente entrar no CanvasLayer
	await get_tree().process_frame
	
	var tween = create_tween()
	
	# 3. MODO PAUSE: Garante que o Fade aconteça mesmo se algo (ou outro script) pausou o jogo
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# Anima apenas o Alpha
	tween.tween_property(tela_preta, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)
	
	tween.finished.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/TelaFimCorrida.tscn")
	)
