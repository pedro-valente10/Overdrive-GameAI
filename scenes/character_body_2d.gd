extends CharacterBody2D

var tween_flutuar: Tween
var pode_correr: bool = false

@onready var seta = $SetaIndicadora

# --- ENVOLVIMENTO DE CATEGORIAS DE CARROS ---
@export_group("Modelos de Carros (Coloque os Sprites correspondentes)")
@export var carros_casuais: Array[Texture2D]
@export var carros_esportivos: Array[Texture2D]
@export var carros_de_luxo: Array[Texture2D]
@export var carros_f1: Array[Texture2D]

@export var sprite: Sprite2D # Certifique-se de que o nó do sprite se chama exatamente Sprite2D
# --------------------------------------------

@export var max_speed = 250.0
@export var acceleration = 1000.0
@export var friction = 800.0
@export var steering_speed = 3.5
var speed_multiplier = 1.0

var voltas_completadas: int = 0
var max_voltas: int = 2
var indice_alvo: int = 0
var lista_waypoints = []


func _ready():
	iniciar_flutuacao()
	
	# Aplica o modelo visual correto no Player baseado no botão clicado
	_atualizar_modelo_player()
	
	var caminho_waypoints = get_node("../Waypoints")
	if caminho_waypoints:
		lista_waypoints = caminho_waypoints.get_children()


func _atualizar_modelo_player() -> void:
	if not sprite: 
		print("Aviso: Nó de sprite do Player não foi encontrado!")
		return
	
	var categoria_escolhida = DadosCorrida.carro_escolhido_id
	var lista_atual: Array[Texture2D] = []
	
	match categoria_escolhida:
		0: lista_atual = carros_casuais
		1: lista_atual = carros_esportivos
		2: lista_atual = carros_de_luxo
		3: lista_atual = carros_f1
		
	if lista_atual.size() > 0:
		var textura_escolhida = lista_atual[0]
		if textura_escolhida is String:
			sprite.texture = load(textura_escolhida)
		else:
			sprite.texture = textura_escolhida
	else:
		print("Aviso: A lista da categoria ", categoria_escolhida, " está vazia no Player!")


func iniciar_flutuacao():
	if not seta: return
	tween_flutuar = create_tween().set_loops()
	var pos_y_inicial = seta.global_position.y 
	tween_flutuar.tween_property(seta, "global_position:y", pos_y_inicial - 10, 0.6).set_trans(Tween.TRANS_SINE)
	tween_flutuar.tween_property(seta, "global_position:y", pos_y_inicial, 0.6).set_trans(Tween.TRANS_SINE)


func sumir_seta() -> Tween:
	if not seta: return null
	
	if tween_flutuar and tween_flutuar.is_valid():
		tween_flutuar.kill()
		
	var tween_sumir = create_tween()
	tween_sumir.tween_property(seta, "modulate:a", 0.0, 0.3)
	tween_sumir.tween_callback(seta.queue_free)
	
	return tween_sumir


func definir_pode_correr(status: bool):
	pode_correr = status


func obter_pontuacao_corrida() -> float:
	return (voltas_completadas * 1000.0) + indice_alvo


func completou_uma_volta():
	voltas_completadas += 1

	if voltas_completadas >= max_voltas:
		var mapa = get_tree().current_scene
		if mapa.has_method("finalizar_corrida"):
			mapa.finalizar_corrida(self)


func _physics_process(delta):
	if not pode_correr: 
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var turn_input = Input.get_axis("ui_left", "ui_right")
	
	# INVERTIDO: Para cima (W) agora é positivo (+1) e para baixo (S) é negativo (-1)
	var drive_input = Input.get_axis("ui_down", "ui_up")

	if velocity.length() > 5:
		# Lógica de ré ajustada para o novo input
		var direction_modifier = -1 if drive_input < 0 else 1
		rotation += turn_input * steering_speed * delta * direction_modifier
 
	var current_max_speed = max_speed * speed_multiplier
	
# EIXO CORRIGIDO: Dizemos à física que a frente do seu carro aponta para Cima
	var direcao_atual = -transform.y
	
	if drive_input != 0:
		var velocidade_desejada = drive_input * current_max_speed
		
		# FÍSICA DE PNEU: O Player agora derrapa e sofre perda de tração lateral!
		velocity = velocity.lerp(direcao_atual * velocidade_desejada, 3.5 * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
	atualizar_waypoint_atual()


func atualizar_waypoint_atual():
	if lista_waypoints.is_empty():
		return
		
	var alvo_atual = lista_waypoints[indice_alvo].global_position

	if global_position.distance_to(alvo_atual) < 150.0:
		indice_alvo += 1
		if indice_alvo >= lista_waypoints.size():
			indice_alvo = 0


func _on_atrito_zebra_body_entered(body: Node2D) -> void:
	if body == self: 
		speed_multiplier = 0.4 


func _on_atrito_zebra_body_exited(body: Node2D) -> void:
	if body == self:
		speed_multiplier = 1.0
