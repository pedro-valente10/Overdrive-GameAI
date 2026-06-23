extends Node2D

var rank_corredores: Array = []
var corrida_finalizada: bool = false 

func _ready() -> void:
	rank_corredores = get_tree().get_nodes_in_group("corredores")
	print("Corredores encontrados no grupo: ", rank_corredores.size())

func _process(_delta):
	atualizar_posicoes()

func atualizar_posicoes(vencedor_absoluto = null):
	var todos_corredores = get_tree().get_nodes_in_group("corredores")
	
	# Ordena os corredores com base no progresso normalizado
	todos_corredores.sort_custom(func(a, b):
		# SEGREDO 1: Se já temos um vencedor definitivo da corrida,
		# ele é forçado a ficar no topo do ranking (Índice 0) independente do score de reset
		if vencedor_absoluto != null:
			if a == vencedor_absoluto: return true
			if b == vencedor_absoluto: return false
			
		return _obter_pontuacao_normalizada(a) > _obter_pontuacao_normalizada(b)
	)
	rank_corredores = todos_corredores

func _obter_pontuacao_normalizada(corredor) -> float:
	var pontuacao = 0.0
	
	# SEGREDO 2: Verifica se o corredor (player ou bot) possui o método de pontuação
	if corredor.has_method("obter_pontuacao_corrida"):
		pontuacao = corredor.obter_pontuacao_corrida()
	else:
		# Fallback de segurança caso o Player utilize variáveis diretas sem o método
		var voltas = corredor.get("voltas_completadas") if corredor.get("voltas_completadas") != null else corredor.get("voltas")
		var indice = corredor.get("indice_alvo") if corredor.get("indice_alvo") != null else corredor.get("indice_waypoint")
		
		if voltas == null: voltas = 0
		if indice == null: indice = 0
		pontuacao = (voltas * 1000.0) + indice

			
	return pontuacao

func finalizar_corrida(vencedor):
	if corrida_finalizada:
		return
	corrida_finalizada = true
	
	# Desativa o _process para congelar o ranking visual síncrono
	set_process(false)
	
	# SEGREDO 4: Desativa o movimento físico de TODOS os carros imediatamente.
	# Isso evita que eles continuem andando e alterando posições no meio do Fade Out.
	for corredor in get_tree().get_nodes_in_group("corredores"):
		if corredor.has_method("definir_pode_correr"):
			corredor.definir_pode_correr(false)
		elif "pode_correr" in corredor:
			corredor.pode_correr = false
	
	vencedor.voltas_completadas = 999
	atualizar_posicoes(vencedor)
	
	# Determina se o jogador humano venceu
	var o_jogador_venceu = (vencedor.name == "player")
	var posicao_final_calculada = 1
	
	if o_jogador_venceu:
		posicao_final_calculada = 1
	else:
		# Busca a posição real e limpa do jogador dentro do ranking corrigido
		var jogador_node = null
		for corredor in rank_corredores:
			if corredor.name == "player":
				jogador_node = corredor
				break
		
		if jogador_node != null:
			posicao_final_calculada = rank_corredores.find(jogador_node) + 1
		else:
			posicao_final_calculada = rank_corredores.size() # Fallback dinâmico (último lugar)
			
	# Removeu-se a "gambiarra" antiga de forçar o jogador a ficar em 2º.
	# Agora o cálculo acima é 100% real e confiável.
	
	# Salva os dados no Autoload DadosCorrida
	DadosCorrida.jogador_venceu = o_jogador_venceu
	DadosCorrida.posicao_final = posicao_final_calculada
	
	print("DEBUG GERENCIADOR - Venceu: ", DadosCorrida.jogador_venceu, " | Posição Salva: ", DadosCorrida.posicao_final)
	
	fazer_fade_out_e_mudar_cena()

func fazer_fade_out_e_mudar_cena():
	var tela_preta = ColorRect.new()
	tela_preta.color = Color.BLACK
	tela_preta.modulate.a = 0.0
	tela_preta.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	$"../CanvasLayer".call_deferred("add_child", tela_preta)
	await get_tree().process_frame
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(tela_preta, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)
	
	tween.finished.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/TelaFimCorrida.tscn")
	)
