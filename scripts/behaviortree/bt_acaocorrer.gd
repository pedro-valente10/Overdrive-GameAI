class_name BTAcaoCorrer extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	if bot.lista_waypoints.is_empty():
		return Status.FAILURE
		
	var alvo_atual = bot.lista_waypoints[bot.indice_alvo].global_position
	
	# CORREÇÃO: direcao_desejada é apenas a direção (normalizada)
	var direcao_desejada = (alvo_atual - bot.global_position).normalized()
	
	# velocidade_desejada é agora um vetor (direção * magnitude)
	var velocidade_desejada = direcao_desejada * bot.velocidade_maxima
	
	# Steering suave: diferença entre velocidade desejada e atual
	var diferenca_velocidade = velocidade_desejada - bot.velocity
	var forca_steering = diferenca_velocidade * bot.forca_curva * delta
	
	# Aplicar força de steering
	bot.velocity += forca_steering
	
	# Verificar se chegou no waypoint
	if bot.global_position.distance_to(alvo_atual) < bot.distancia_alvo:
		bot.indice_alvo += 1
		if bot.indice_alvo >= bot.lista_waypoints.size():
			bot.indice_alvo = 0
			bot.completou_uma_volta()  # CORREÇÃO: faltava chamar isso!
			
	return Status.SUCCESS
