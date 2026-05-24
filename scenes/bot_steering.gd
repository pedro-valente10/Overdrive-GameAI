extends CharacterBody2D

var pode_correr: bool = false
@export var velocidade_maxima = 275.0
@export var forca_curva = 4.0
@export var distancia_alvo = 90.0

# --- VARIÁVEIS DE PERSONALIDADE ---
@export_group("Personalidade do Piloto")
@export var fator_frenagem_desvio: float = 0.7 # 1.0 = não freia, 0.3 = freia muito
@export var multiplicador_tangente: float = 1.2 # Força de manobra lateral
@export var alcance_visao: float = 100.0 # Comprimento dos sensores

@onready var arvore_comportamento = $BehaviorTree # Puxa o topo da árvore

var lista_waypoints = []
var indice_alvo = 0

func _ready():
	# Lógica original dos waypoints
	var caminho_waypoints = get_node("../Waypoints")
	if caminho_waypoints:
		lista_waypoints = caminho_waypoints.get_children()
		
	# Ajusta dinamicamente o tamanho de TODOS os RayCast2D filhos deste bot
	for filho in get_children():
		if filho is RayCast2D:
			# Mantém a direção original do raio, mas aplica o novo alcance de visão
			filho.target_position = filho.target_position.normalized() * alcance_visao

func definir_pode_correr(status: bool):
	pode_correr = status

func _physics_process(delta):
	# Se a corrida não começou, fica parado e encerra o processamento deste frame
	if not pode_correr: 
		velocity = Vector2.ZERO
		move_and_slide()
		return # O return impede que a IA calcule rotas antes da largada
		
	# Só processa a IA se estiver autorizado a correr
	if arvore_comportamento:
		arvore_comportamento.tick(self, delta)
		
	# Rotaciona visualmente o carro para a direção da velocidade
	if velocity.length() > 0:
		rotation = velocity.angle()
		
	# Aplica o movimento final do frame
	move_and_slide()
