class_name BTAcaoDesviar extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	var normal_colisao = Vector2.ZERO
	var batendo = false
	
	# Detectar colisão com RayCasts
	for filho in bot.find_children("*", "RayCast2D", true, false):
		if filho.is_colliding():
			normal_colisao += filho.get_collision_normal()
			batendo = true
			
	if not batendo:
		return Status.FAILURE
		
	normal_colisao = normal_colisao.normalized()
	
	# Vetor tangente (perpendicular à normal)
	var vetor_tangente = Vector2(-normal_colisao.y, normal_colisao.x)
	
	# Decidir qual lado é melhor para desviar
	var tendencia_desvio = bot.velocity.dot(vetor_tangente)
	var limiar = bot.velocidade_maxima * 0.05
	
	if abs(tendencia_desvio) < limiar:
		# Desempate: usa posição Y
		if bot.global_position.y > bot.get_viewport_rect().size.y / 2.0:
			vetor_tangente = -vetor_tangente
	elif tendencia_desvio < 0:
		vetor_tangente = -vetor_tangente
		
	# Direção de fuga (lateral + um pouco de recuo)
	var direcao_fuga = (normal_colisao * 0.2 + vetor_tangente * bot.multiplicador_tangente).normalized()
	
	# Suavizar desvio (interpolar com direção atual)
	var direcao_atual = bot.velocity.normalized()
	var direcao_fuga_suave = direcao_fuga.lerp(direcao_atual, 0.3).normalized()
	
	# Velocidade reduzida em desvio
	var velocidade_fuga = direcao_fuga_suave * (bot.velocidade_maxima * bot.fator_frenagem_desvio)
	
	# Aplicar steering
	var forca_steering = (velocidade_fuga - bot.velocity) * bot.forca_curva * delta
	bot.velocity += forca_steering
	
	# Verificar se ainda há colisão
	for filho in bot.find_children("*", "RayCast2D", true, false):
		if filho.is_colliding():
			return Status.RUNNING
	
	return Status.SUCCESS
