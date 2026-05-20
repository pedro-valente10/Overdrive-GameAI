extends CharacterBody2D

var pode_correr: bool = false
@export var velocidade_maxima = 275.0
@export var forca_curva = 4.0
@export var distancia_alvo = 90.0

@onready var sensor_frente = $RayCast2D
@onready var arvore_comportamento = $BehaviorTree # Puxa o topo da árvore

var lista_waypoints = []
var indice_alvo = 0


func _ready():
	var caminho_waypoints = get_node("../Waypoints")
	if caminho_waypoints:
		lista_waypoints = caminho_waypoints.get_children()
	
func definir_pode_correr(status: bool):
	pode_correr = status

func _physics_process(delta):
	# O tick inicial faz a magia da recursividade rodar a árvore toda
	if arvore_comportamento:
		arvore_comportamento.tick(self, delta)
	
	if not pode_correr: 
		velocity = Vector2.ZERO
		move_and_slide()
		
	if velocity.length() > 0:
		rotation = velocity.angle()
		
	move_and_slide()
