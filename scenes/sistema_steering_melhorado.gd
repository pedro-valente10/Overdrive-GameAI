class_name BTSistemaSteeringMelhorado extends BTNode

# Este módulo centraliza toda a lógica de movimento suave do bot
# Substitui a mistura de steering direto em bt_acaocorrer e bt_acaodesviar

# --- CONFIGURAÇÕES DE CONTROLE ---
# Quanto mais alto, mais "viscoso" o carro (sente resistência ao virar)
@export var dumping_factor: float = 0.85  # 0-1: efeito de amortecimento
@export var max_steering_force: float = 1.5  # força máxima de steering por frame

# --- ROTAÇÃO DO CARRO ---
# Garante que o sprite gira naturalmente (não salta de ângulo)
@export var rotation_smoothing: float = 12.0  # velocidade de rotação suave

func aplicar_steering_suave(bot: CharacterBody2D, 
							 direcao_desejada: Vector2, 
							 velocidade_desejada: float, 
							 delta: float) -> void:
	"""
	Aplica steering suave com amortecimento físico.
	
	Parâmetros:
	- bot: o CharacterBody2D do bot
	- direcao_desejada: Vector2.normalized() para onde quer ir
	- velocidade_desejada: escalar (0 a max_speed)
	- delta: frame time
	"""
	
	# 1. CALCULAR STEERING FORCE (diferença entre velocidade atual e desejada)
	var velocidade_alvo = direcao_desejada * velocidade_desejada
	var diferenca_velocidade = velocidade_alvo - bot.velocity
	
	# 2. APLICAR AMORTECIMENTO (dumping_factor reduz overshoot)
	# Isso faz o carro "sentir" mais peso e menos saltitante
	var forca_steering = diferenca_velocidade * bot.forca_curva * delta
	forca_steering = forca_steering.limit_length(max_steering_force)
	
	# 3. INTERPOLAÇÃO SUAVE (evita mudanças bruscas)
	# dumping_factor alto = mais lento em alcançar o alvo (realista)
	bot.velocity = bot.velocity.lerp(bot.velocity + forca_steering, 1.0 - dumping_factor)
	
	# 4. LIMITAR VELOCIDADE (não deixa passar do máximo)
	bot.velocity = bot.velocity.limit_length(velocidade_desejada)
	
	# 5. ATUALIZAR ROTAÇÃO DO SPRITE (suave, não instantâneo)
	if bot.velocity.length() > 5.0:  # só rota se tiver movimento
		var angulo_desejado = bot.velocity.angle()
		bot.rotation = lerp_angle(bot.rotation, angulo_desejado, delta * rotation_smoothing)

func calcular_frenagem_curva(bot: CharacterBody2D, 
							   alvo_proximo: Vector2) -> float:
	"""
	Reduz a velocidade ao se aproximar de curvas cerradas.
	Torna a direção muito mais realista e evita capotamentos.
	
	Retorna: multiplicador de velocidade (0.0 a 1.0)
	"""
	
	var direcao_alvo = (alvo_proximo - bot.global_position).normalized()
	var direcao_movimento = bot.velocity.normalized()
	
	# Quanto menor o ângulo entre direção atual e alvo, mais direto é o caminho
	var angulo_diferenca = direcao_movimento.angle_to(direcao_alvo)
	
	# Se o ângulo é > 45 graus (0.785 rad), começa a frear
	var limiar_curva = PI / 4.0  # 45 graus
	
	if abs(angulo_diferenca) > limiar_curva:
		# Frena proporcionalmente ao ângulo
		# Em 90 graus: frena para 50% da velocidade
		var frenagem = 1.0 - (abs(angulo_diferenca) - limiar_curva) / PI
		return max(0.5, frenagem)  # mínimo de 50% de velocidade
	
	return 1.0  # velocidade normal

func tick(bot: CharacterBody2D, delta: float) -> int:
	# Este é apenas o nó base; as ações o chamam
	return Status.FAILURE
