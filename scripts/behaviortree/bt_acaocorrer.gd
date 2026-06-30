class_name BTAcaoCorrer extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	if bot.lista_waypoints.is_empty():
		return Status.FAILURE
		
	var alvo_atual = bot.lista_waypoints[bot.indice_alvo].global_position
	var direcao_desejada = (alvo_atual - bot.global_position).normalized()
	
	# --- 1. HUMANIZAÇÃO: FRENAGEM EM CURVAS ---
	var direcao_movimento = bot.velocity.normalized()
	var multiplicador_velocidade = 1.0
	
	# Só calcula curva se o carro já tiver alguma velocidade
	if bot.velocity.length() > 10.0:
		var angulo_diferenca = direcao_movimento.angle_to(direcao_desejada)
		
		# Se a curva for mais fechada que 45 graus (PI/4), o piloto humano tira o pé do acelerador
		if abs(angulo_diferenca) > PI / 4.0: 
			multiplicador_velocidade = max(0.4, 1.0 - (abs(angulo_diferenca) / PI))

	var velocidade_desejada = direcao_desejada * (bot.velocidade_maxima * multiplicador_velocidade)
	
	# --- 2. DIREÇÃO SUAVE ---
	var forca_steering = (velocidade_desejada - bot.velocity) * bot.forca_curva * delta
	
	bot.velocity += forca_steering
	
	# --- 3. PROGRESSÃO DE WAYPOINTS ---
	if bot.global_position.distance_to(alvo_atual) < bot.distancia_alvo:
		bot.indice_alvo += 1
		if bot.indice_alvo >= bot.lista_waypoints.size():
			bot.indice_alvo = 0
			bot.completou_uma_volta()
			
	return Status.SUCCESS
