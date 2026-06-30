class_name BTAcaoDesviar extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	var normal_colisao = Vector2.ZERO
	var batendo = false
	var perigo_frontal = false
	var distancia_perigo = 9999.0
	
	for filho in bot.find_children("*", "RayCast2D", true, false):
		if filho.is_colliding():
			normal_colisao += filho.get_collision_normal()
			batendo = true
			if filho.target_position.x > abs(filho.target_position.y):
				perigo_frontal = true
				# Descobre a qual distância o outro carro / parede está
				var dist = bot.global_position.distance_to(filho.get_collision_point())
				distancia_perigo = min(distancia_perigo, dist)
			
	if not batendo:
		return Status.FAILURE
		
	normal_colisao = normal_colisao.normalized()
	
	var vetor_tangente = Vector2(-normal_colisao.y, normal_colisao.x)
	var direcao_frente = Vector2.RIGHT.rotated(bot.rotation)
	
	if direcao_frente.dot(vetor_tangente) < 0:
		vetor_tangente = -vetor_tangente
		
	var direcao_fuga = (normal_colisao * 0.5 + vetor_tangente * 1.5).normalized()
	var diferenca_angulo = angle_difference(bot.rotation, direcao_fuga.angle())
	
	# --- REAÇÃO DO VOLANTE (AGRESSIVIDADE) ---
	# Pilotos agressivos dão "golpes" rápidos no volante para trocar de faixa
	bot.volante = clamp(diferenca_angulo * 3.0 * bot.agressividade_volante, -1.0, 1.0)
	
	# --- REAÇÃO DOS PEDAIS (CORAGEM) ---
	if perigo_frontal:
		# Distância de Pânico: 
		# Coragem 2.0 (Agressivo) = Só afunda o freio a 50 pixels da batida (Tira fina)
		# Coragem 0.5 (Medroso) = Afunda o freio a 200 pixels da batida
		var distancia_panico = 100.0 / bot.coragem
		
		if distancia_perigo < distancia_panico:
			bot.pedal_acelerador = -1.0 # Pânico! Trava as rodas / Engata ré
		else:
			bot.pedal_acelerador = -0.2 # Só "tira o pé" do acelerador e freia de levinho
	else:
		# Retoma a aceleração no meio do desvio
		bot.pedal_acelerador = 0.5 * bot.coragem 
	
	for filho in bot.find_children("*", "RayCast2D", true, false):
		if filho.is_colliding():
			return Status.RUNNING
	
	return Status.SUCCESS
