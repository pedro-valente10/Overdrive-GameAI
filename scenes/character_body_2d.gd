extends CharacterBody2D


var tween_flutuar: Tween
var pode_correr: bool = false

@onready var seta = $SetaIndicadora
@export var max_speed = 275.0
@export var acceleration = 1000.0
@export var friction = 800.0
@export var steering_speed = 3.5
var speed_multiplier = 1.0


var voltas_completadas: int = 0
var max_voltas: int = 6
var indice_alvo: int = 0
var lista_waypoints = []

func _ready():
	iniciar_flutuacao()
	var caminho_waypoints = get_node("../Waypoints")
	if caminho_waypoints:
		lista_waypoints = caminho_waypoints.get_children()

func iniciar_flutuacao():
	if not seta: return
	tween_flutuar = create_tween().set_loops()
	tween_flutuar.tween_property(seta, "position:y", seta.position.y - 10, 0.6).set_trans(Tween.TRANS_SINE)
	tween_flutuar.tween_property(seta, "position:y", seta.position.y, 0.6).set_trans(Tween.TRANS_SINE)

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
	var drive_input = Input.get_axis("ui_up", "ui_down")

	if velocity.length() > 5:
		var direction_modifier = -1 if drive_input > 0 else 1
		rotation += turn_input * steering_speed * delta * direction_modifier
 
	var current_max_speed = max_speed * speed_multiplier
	
	if drive_input != 0:
		velocity += (transform.y * drive_input) * acceleration * delta
		velocity = velocity.limit_length(current_max_speed)
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
