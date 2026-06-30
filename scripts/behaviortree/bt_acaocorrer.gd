class_name BTAcaoCorrer extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	if bot.lista_waypoints.is_empty():
		return Status.FAILURE
		
	var alvo_atual = bot.lista_waypoints[bot.indice_alvo].global_position
	var distancia = bot.global_position.distance_to(alvo_atual)
	var direcao_alvo_real = bot.global_position.direction_to(alvo_atual)
	
	# --- 1. OLHANDO PARA O FUTURO ---
	var indice_proximo = (bot.indice_alvo + 1) % bot.lista_waypoints.size()
	var alvo_proximo = bot.lista_waypoints[indice_proximo].global_position
	
	var direcao_futura = alvo_atual.direction_to(alvo_proximo)
	var angulo_da_curva_futura = angle_difference(direcao_alvo_real.angle(), direcao_futura.angle())
	
	# --- 2. A MÁGICA DA TANGÊNCIA ---
	var fator_proximidade = clamp(1.0 - (distancia / 200.0), 0.0, 1.0) 
	var peso_tangente = fator_proximidade * 0.5 * bot.multiplicador_tangente
	var ponto_de_tangencia = alvo_atual.lerp(alvo_proximo, peso_tangente)
	
	var direcao_volante = bot.global_position.direction_to(ponto_de_tangencia)
	var diferenca_angulo_atual = angle_difference(bot.rotation, direcao_volante.angle())
	
	# Mãos no volante
	bot.volante = clamp(diferenca_angulo_atual * 2.0, -1.0, 1.0)
	
	# --- 3. PÉ NOS PEDAIS (FREAR ANTES E ACELERAR PROGRESSIVAMENTE) ---
	var velocidade_relativa = bot.velocidade_atual / bot.velocidade_maxima
	var forca_g_atual = abs(diferenca_angulo_atual) * velocidade_relativa
	var forca_g_futura = abs(angulo_da_curva_futura) * velocidade_relativa * fator_proximidade
	
	var zona_conforto_freio = 0.35 * bot.coragem
	var limite_panico = 0.5 * bot.coragem
	
	# A) Frenagem ANTES da curva (Aproximação)
	if forca_g_futura > zona_conforto_freio and fator_proximidade > 0.1:
		bot.pedal_acelerador = -1.0
		
	# B) Frenagem de Emergência (Se entrou absurdamente rápido e está perdendo a curva)
	elif forca_g_atual > limite_panico and velocidade_relativa > 0.6:
		bot.pedal_acelerador = -1.0
		
	# C) O SEGREDO: ACELERAÇÃO PROGRESSIVA (Meio e Saída de Curva)
	elif abs(diferenca_angulo_atual) > 0.05:
		# Quanto mais virado o volante estiver, menos ele acelera (ex: 30% do pedal no meio da curva).
		# Conforme ele endireita o carro saindo da curva, o pedal sobe automaticamente para 100%.
		var progressao = 1.0 - (abs(diferenca_angulo_atual) / (PI / 1.5))
		bot.pedal_acelerador = clamp(progressao, 0.3, 1.0)
		
	# D) Reta Livre
	else:
		bot.pedal_acelerador = 1.0
		
	# --- 4. PROGRESSÃO DE WAYPOINTS ---
	var direcao_frente = Vector2.RIGHT.rotated(bot.rotation)
	var passou_waypoint = direcao_frente.dot(direcao_alvo_real) < 0.0
	
	if distancia < bot.distancia_alvo or (passou_waypoint and distancia < 250.0):
		bot.indice_alvo += 1
		if bot.indice_alvo >= bot.lista_waypoints.size():
			bot.indice_alvo = 0
			bot.completou_uma_volta()
			
	return Status.SUCCESS
