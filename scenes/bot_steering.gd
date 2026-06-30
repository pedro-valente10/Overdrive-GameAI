extends CharacterBody2D

var pode_correr: bool = false

@export var texturas_dos_carros: Array[Texture2D]
@onready var sprite = $Sprite2D

# ============================================
# MOVIMENTO BASE
# ============================================
@export_group("Movimento Base")
@export var velocidade_maxima: float = 275.0
@export var forca_curva: float = 3.0
@export var distancia_alvo: float = 90.0

# ============================================
# STEERING SUAVE - FASE 1
# ============================================
@export_group("Steering Suave")
@export var dumping_factor: float = 0.85  # 0-1: quanto mais alto, mais viscoso (suave)
@export var rotation_smoothing: float = 12.0  # velocidade de rotação suave do sprite
@export var max_steering_force: float = 1.5  # força máxima de steering por frame

# ============================================
# DETECÇÃO DE CURVAS - FASE 1
# ============================================
@export_group("Curvas e Frenagem")
@export var limiar_curva_graus: float = 45.0  # ângulo para começar a frear (em graus)
@export var multiplicador_frenagem_curva: float = 0.5  # quanto frena (0.5 = 50% velocidade)
@export var distancia_deteccao_curva: float = 150.0  # distância olhar adiante

# ============================================
# PERSONALIDADE DO PILOTO
# ============================================
@export_group("Personalidade do Piloto")
@export var fator_frenagem_desvio: float = 0.7  # quanto frena ao desviar (0-1)
@export var multiplicador_tangente: float = 1.2  # agressividade do desvio (0.5-3.0)
@export var alcance_visao: float = 100.0  # distância dos sensores RayCast

# ============================================
# DESVIO INTELIGENTE - FASE 1
# ============================================
@export_group("Desvio Inteligente")
@export var agressividade_desvio: float = 1.5  # quanto mais alto, mais agressivo (0.5-3.0)
@export var tempo_desvio_minimo: float = 0.3  # tempo mínimo em desvio (segundos)
@export var frenagem_emergencial_rate: float = 1200.0  # quanto freia rápido ao detectar colisão

# ============================================
# REFERÊNCIAS
# ============================================
@onready var arvore_comportamento = $BehaviorTree

# ============================================
# VARIÁVEIS DE RUNTIME
# ============================================
var lista_waypoints: Array = []
var indice_alvo: int = 0
var voltas_completadas: int = 0
var max_voltas: int = 6

# ============================================
# READY - Inicialização
# ============================================
func _ready() -> void:
	# Carregar waypoints
	var caminho_waypoints = get_node("../Waypoints")
	if caminho_waypoints:
		lista_waypoints = caminho_waypoints.get_children()
	
	# Definir textura aleatória
	if texturas_dos_carros.size() > 0:
		var textura_escolhida = texturas_dos_carros.pick_random()
		if textura_escolhida is String:
			sprite.texture = load(textura_escolhida)
		else:
			sprite.texture = textura_escolhida
	
	# Configurar alcance de visão dos RayCasts
	for filho in get_children():
		if filho is RayCast2D:
			filho.target_position = filho.target_position.normalized() * alcance_visao
	
	print("Bot %s pronto | Waypoints: %d | Dumping: %.2f | Agressividade: %.2f" % [
		name, 
		lista_waypoints.size(),
		dumping_factor,
		agressividade_desvio
	])

# ============================================
# PHYSICS PROCESS - Loop Principal
# ============================================
func _physics_process(delta: float) -> void:
	# Se não pode correr, fica parado
	if not pode_correr:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Executar árvore de comportamento
	if arvore_comportamento:
		arvore_comportamento.tick(self, delta)
	
	# Atualizar rotação do sprite (suave)
	_atualizar_rotacao_sprite(delta)
	
	# Aplicar movimento
	move_and_slide()

# ============================================
# MÉTODOS AUXILIARES - Rotação
# ============================================

func _atualizar_rotacao_sprite(delta: float) -> void:
	"""
	Atualiza a rotação do sprite de forma suave.
	Usa rotation_smoothing para controlar a velocidade.
	"""
	if velocity.length() > 5.0:
		var angulo_desejado = velocity.angle()
		rotation = lerp_angle(rotation, angulo_desejado, delta * rotation_smoothing)

# ============================================
# MÉTODOS PÚBLICOS - Controle
# ============================================

func definir_pode_correr(status: bool) -> void:
	"""Define se o bot pode se mover."""
	pode_correr = status

func obter_pontuacao_corrida() -> float:
	"""Retorna pontuação atual (voltas + progresso)."""
	return (voltas_completadas * 1000.0) + indice_alvo

func completou_uma_volta() -> void:
	"""Chamado quando completa uma volta."""
	voltas_completadas += 1
	indice_alvo = 0
	
	if voltas_completadas >= max_voltas:
		var mapa = get_tree().current_scene
		if mapa.has_method("finalizar_corrida"):
			mapa.finalizar_corrida(self)

# ============================================
# MÉTODOS PÚBLICOS - Informações
# ============================================

func obter_waypoint_atual() -> Vector2:
	"""Retorna posição do waypoint atual."""
	if lista_waypoints.is_empty():
		return global_position
	return lista_waypoints[indice_alvo].global_position

func obter_waypoint_proximo() -> Vector2:
	"""Retorna posição do próximo waypoint (para detecção de curvas)."""
	if lista_waypoints.is_empty():
		return global_position
	var proximo_idx = (indice_alvo + 1) % lista_waypoints.size()
	return lista_waypoints[proximo_idx].global_position

func obter_distancia_para_waypoint() -> float:
	"""Retorna distância até o waypoint atual."""
	return global_position.distance_to(obter_waypoint_atual())

# ============================================
# MÉTODOS AUXILIARES - Cálculos
# ============================================

func calcular_angulo_curva() -> float:
	"""
	Calcula o ângulo entre a direção atual e o próximo waypoint.
	Retorna o ângulo em radianos.
	"""
	if velocity.length() < 5.0:
		return 0.0
	
	var direcao_atual = velocity.normalized()
	var proximo = obter_waypoint_proximo()
	var direcao_proxima = (proximo - global_position).normalized()
	
	return direcao_atual.angle_to(direcao_proxima)

func obter_multiplicador_frenagem_curva() -> float:
	"""
	Calcula quanto frear baseado no ângulo da curva.
	Retorna multiplicador de velocidade (0.0 a 1.0).
	"""
	var angulo_curva = calcular_angulo_curva()
	var limiar_rad = deg_to_rad(limiar_curva_graus)
	
	# Se ângulo é menor que o limiar, velocidade normal
	if abs(angulo_curva) <= limiar_rad:
		return 1.0
	
	# Frena proporcionalmente ao ângulo
	var frenagem = 1.0 - (abs(angulo_curva) - limiar_rad) / PI
	return max(multiplicador_frenagem_curva, frenagem)

# ============================================
# DEBUG
# ============================================

func debug_info() -> String:
	"""Retorna string com informações de debug."""
	return "[%s] Vel: %.0f | Voltas: %d/%d | Waypoint: %d | Ângulo: %.1f°" % [
		name,
		velocity.length(),
		voltas_completadas,
		max_voltas,
		indice_alvo,
		rad_to_deg(calcular_angulo_curva())
	]
