class_name BTAcaoDesviar extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	var normal_colisao = Vector2.ZERO
	var batendo = false
	
	# 1. Lê todos os RayCast2D que estão dentro do node "Sensores"
	for sensor in bot.get_node("Sensores").get_children():
		if sensor.is_colliding():
			normal_colisao += sensor.get_collision_normal()
			batendo = true
			
	# 2. Se nenhum sensor detectou colisão, o bot não precisa desviar
	if not batendo:
		return Status.FAILURE
		
	# 3. Normaliza o vetor resultante (caso mais de um sensor tenha batido ao mesmo tempo)
	normal_colisao = normal_colisao.normalized()
	
	# 4. Encontra o vetor tangente (ortogonal) para deslizar pela lateral
	var vetor_tangente = Vector2(-normal_colisao.y, normal_colisao.x)
	
	# 5. Usa o produto escalar para escolher o lado mais rápido para o desvio
	if bot.velocity.dot(vetor_tangente) < 0:
		vetor_tangente = -vetor_tangente
		
	# 6. Calcula a direção de fuga misturando a normal e a tangente
	var direcao_fuga = (normal_colisao * 0.4 + vetor_tangente * 1.2).normalized()
	
	# 7. Calcula a velocidade desejada aplicando a penalidade de momento (ex: 70% da vel máx)
	var velocidade_fuga = direcao_fuga * (bot.velocidade_maxima * 0.7)
	
	# 8. Aplica a força de steering
	var forca_steering = (velocidade_fuga - bot.velocity) * (bot.forca_curva * 2.0) * delta
	
	bot.velocity += forca_steering
	
	return Status.SUCCESS
