extends CharacterBody2D

# --- VARIÁVEIS DE FÍSICA E STEERING ---
var velocidade_maxima = 350.0
var forca_curva = 4.0 # Quão rápido ele consegue girar o volante
var distancia_alvo = 150.0 # Distância para considerar que chegou no waypoint

# --- MÁQUINA DE ESTADOS (FSM) ---
enum Estado { CORRENDO, DESVIANDO }
var estado_atual = Estado.CORRENDO

# --- WAYPOINTS ---
@onready var caminho_waypoints = get_node("../Waypoints")
@onready var sensor_frente = $RayCast2D # O nó RayCast2D que você criou no bot
var lista_waypoints = []
var indice_alvo = 0

func _ready():
	# Coleta todos os Marker2D criados na pasta Waypoints
	if caminho_waypoints:
		lista_waypoints = caminho_waypoints.get_children()

func _physics_process(delta):
	if lista_waypoints.is_empty():
		return
		
	# 1. Verifica transições da Máquina de Estados (FSM)
	verificar_estado()
	
	# 2. Executa a ação baseada no estado atual
	match estado_atual:
		Estado.CORRENDO:
			estado_correndo(delta)
		Estado.DESVIANDO:
			estado_desviando(delta)
			
	# Atualiza a rotação do sprite para olhar para onde está indo
	if velocity.length() > 0:
		rotation = velocity.angle()
		
	move_and_slide()

# --- LÓGICA DA FSM ---
func verificar_estado():
	# Se o raycast bater em algo (parede ou o player), muda para DESVIANDO
	if sensor_frente.is_colliding():
		estado_atual = Estado.DESVIANDO
	else:
		estado_atual = Estado.CORRENDO

# --- ESTADO 1: CORRENDO (Steering Behavior: Seek) ---
func estado_correndo(delta):
	var alvo_atual = lista_waypoints[indice_alvo].global_position
	
	# Calcula a Força de Steering
	var direcao_desejada = (alvo_atual - global_position).normalized()
	var velocidade_desejada = direcao_desejada * velocidade_maxima
	var forca_steering = (velocidade_desejada - velocity) * forca_curva * delta
	
	# Aplica a física
	velocity += forca_steering
	
	# Se chegou perto do waypoint, muda para o próximo
	if global_position.distance_to(alvo_atual) < distancia_alvo:
		indice_alvo += 1
		# Se passou do último, volta para o primeiro (Loop da corrida)
		if indice_alvo >= lista_waypoints.size():
			indice_alvo = 0

# --- ESTADO 2: DESVIANDO (Steering Behavior: Avoidance) ---
func estado_desviando(delta):
	var ponto_colisao = sensor_frente.get_collision_point()
	var normal_colisao = sensor_frente.get_collision_normal()
	
	# Calcula uma força de repulsão baseada na normal da batida (afasta do obstáculo)
	var velocidade_fuga = normal_colisao * velocidade_maxima
	var forca_steering = (velocidade_fuga - velocity) * (forca_curva * 2) * delta
	
	velocity += forca_steering
