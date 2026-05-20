class_name BTAcaoCorrer extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	if bot.lista_waypoints.is_empty():
		return Status.FAILURE
		
	var alvo_atual = bot.lista_waypoints[bot.indice_alvo].global_position
	
	var direcao_desejada = (alvo_atual - bot.global_position).normalized()
	var velocidade_desejada = direcao_desejada * bot.velocidade_maxima
	var forca_steering = (velocidade_desejada - bot.velocity) * bot.forca_curva * delta
	
	bot.velocity += forca_steering
	
	if bot.global_position.distance_to(alvo_atual) < bot.distancia_alvo:
		bot.indice_alvo += 1
		if bot.indice_alvo >= bot.lista_waypoints.size():
			bot.indice_alvo = 0
			
	return Status.SUCCESS
