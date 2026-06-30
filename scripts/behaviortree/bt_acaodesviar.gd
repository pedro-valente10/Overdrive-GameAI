class_name BTAcaoDesviar extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	var normal_colisao = Vector2.ZERO
	var batendo = false
	
	# find_children busca recursivamente, encontrando RayCast2D dentro de sub-nós
	for filho in bot.find_children("*", "RayCast2D", true, false):
		if filho.is_colliding():
			normal_colisao += filho.get_collision_normal()
			batendo = true
			
	if not batendo:
		return Status.FAILURE
		
	normal_colisao = normal_colisao.normalized()
	
	# Encontra o vetor tangente (ortogonal) para deslizar pela lateral
	var vetor_tangente = Vector2(-normal_colisao.y, normal_colisao.x)
	
	# Desempate: usa o produto escalar para saber de qual lado é mais fácil desviar
	var tendencia_desvio = bot.velocity.dot(vetor_tangente)
	
	# Limiar proporcional à velocidade máxima (5%), evita valor fixo frágil
	var limiar = bot.velocidade_maxima * 0.05
	
	if abs(tendencia_desvio) < limiar:
		# Carros perfeitamente alinhados: usa posição Y para desempatar
		if bot.global_position.y > bot.get_viewport_rect().size.y / 2.0:
			vetor_tangente = -vetor_tangente
	elif tendencia_desvio < 0:
		vetor_tangente = -vetor_tangente
		
	# Direção de fuga agressiva (prioriza muito mais as laterais)
	var direcao_fuga = (normal_colisao * 0.2 + vetor_tangente * 2.0).normalized()
	
	# Suaviza o desvio interpolando com a direção atual do carro (evita virada brusca)
	var direcao_atual = bot.velocity.normalized()
	var direcao_fuga_suave = direcao_fuga.lerp(direcao_atual, 0.3).normalized()
	
	# Velocidade calculada com a personalidade
	var velocidade_fuga = direcao_fuga_suave * (bot.velocidade_maxima * bot.fator_frenagem_desvio)
	
	# Aplica a força de steering com curva reduzida (era 4.0, agora 2.0 para suavidade)
	var forca_steering = (velocidade_fuga - bot.velocity) * (bot.forca_curva * 2.0) * delta
	
	bot.velocity += forca_steering
	
	# Verifica se ainda há risco de colisão APÓS aplicar o steering
	# Enquanto houver, mantém o controle e impede BTAcaoCorrer de rodar
	for filho in bot.find_children("*", "RayCast2D", true, false):
		if filho.is_colliding():
			return Status.RUNNING
	
	# Saiu do raio de perigo: libera o controle para BTAcaoCorrer retomar a rota
	return Status.SUCCESS
