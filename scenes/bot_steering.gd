extends CharacterBody2D

var pode_correr: bool = false

@export var texturas_dos_carros: Array[Texture2D]
@onready var sprite = $Sprite2D

@export var velocidade_maxima = 275.0
@export var forca_curva = 3.0
@export var distancia_alvo = 90.0

# --- VARIÁVEIS DE PERSONALIDADE ---
@export_group("Personalidade do Piloto")
@export var fator_frenagem_desvio: float = 0.7 
@export var multiplicador_tangente: float = 1.2
@export var alcance_visao: float = 100.0

@onready var arvore_comportamento = $BehaviorTree

var lista_waypoints = []
var indice_alvo = 0

var voltas_completadas: int = 0
var max_voltas: int = 6

func _ready():
	var caminho_waypoints = get_node("../Waypoints")
	if caminho_waypoints:
		lista_waypoints = caminho_waypoints.get_children()
	
	if texturas_dos_carros.size() > 0:
		var textura_escolhida = texturas_dos_carros.pick_random()
		if textura_escolhida is String:
			sprite.texture = load(textura_escolhida)
		else:
			sprite.texture = textura_escolhida
		

	for filho in get_children():
		if filho is RayCast2D:
			filho.target_position = filho.target_position.normalized() * alcance_visao


func definir_pode_correr(status: bool):
	pode_correr = status


func obter_pontuacao_corrida() -> float:
	return (voltas_completadas * 1000.0) + indice_alvo


func completou_uma_volta():
	voltas_completadas += 1
	indice_alvo = 0
	

	if voltas_completadas >= max_voltas:
		var mapa = get_tree().current_scene
		if mapa.has_method("finalizar_corrida"):
			mapa.finalizar_corrida(self)

func _physics_process(delta):
	if not pode_correr: 
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	if arvore_comportamento:
		arvore_comportamento.tick(self, delta)
		
	if velocity.length() > 0:
		rotation = lerp_angle(rotation, velocity.angle(), delta * 8.0)
		
	move_and_slide()
