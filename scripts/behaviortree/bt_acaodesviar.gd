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
	
	# Puxa o volante violentamente para a rota de fuga
	bot.volante = clamp(diferenca_angulo * 3.0 * bot.agressividade_volante, -1.0, 1.0)
	
	# --- O FIM DO ENGARRAFAMENTO FANTASMA ---
	if perigo_frontal:
		# Reduzimos um pouco a zona de pânico para eles serem mais ousados
		var distancia_panico = 80.0 / bot.coragem
		
		if distancia_perigo < distancia_panico:
			# Só pisa no freio a fundo se estiver quase batendo no para-choque da frente
			bot.pedal_acelerador = -1.0 
		else:
			# AQUI ESTÁ O SEGREDO: Em vez de frear (-0.2), ele mantém o motor cheio!
			# Um piloto agressivo (coragem alta) pisa fundo (1.0) pra passar raspando,
			# Um medroso alivia o pé (0.5), mas NÃO usa o freio!
			bot.pedal_acelerador = clamp(0.8 * bot.coragem, 0.4, 1.0)
	else:
		# Se o perigo for só lateral, ignora e acelera 100%
		bot.pedal_acelerador = 1.0
	
	for filho in bot.find_children("*", "RayCast2D", true, false):
		if filho.is_colliding():
			return Status.RUNNING
	
	return Status.SUCCESS
