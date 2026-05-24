extends CharacterBody2D

var pode_correr: bool = false

@export var texturas_dos_carros: Array[Texture2D]
@onready var sprite = $Sprite2D

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

# --- VARIÁVEIS DA CORRIDA ---
var voltas_completadas: int = 0
var max_voltas: int = 6

func _ready():
	# 1. Lógica original dos waypoints
	var caminho_waypoints = get_node("../Waypoints")
	if caminho_waypoints:
		lista_waypoints = caminho_waypoints.get_children()
	
	# 2. Sorteia a textura visual do carro (versão limpa e segura)
	if texturas_dos_carros.size() > 0:
		var textura_escolhida = texturas_dos_carros.pick_random()
		if textura_escolhida is String:
			sprite.texture = load(textura_escolhida)
		else:
			sprite.texture = textura_escolhida
		
	# 3. Ajusta dinamicamente o tamanho de TODOS os RayCast2D filhos deste bot
	for filho in get_children():
		if filho is RayCast2D:
			# Mantém a direção original do raio, mas aplica o novo alcance de visão
			filho.target_position = filho.target_position.normalized() * alcance_visao

# Função chamada pelo mapa na Contagem Regressiva
func definir_pode_correr(status: bool):
	pode_correr = status

# Função usada pelo Gerenciador para fazer o Rank de 1º, 2º e 3º lugar
func obter_pontuacao_corrida() -> float:
	return (voltas_completadas * 1000.0) + indice_alvo

# Função chamada pelo nó de Linha de Chegada
func completou_uma_volta():
	voltas_completadas += 1
	indice_alvo = 0 # Reseta os waypoints para a nova volta
	
	# Se chegou em 5 voltas, avisa o mapa que a corrida acabou!
	if voltas_completadas >= max_voltas:
		var mapa = get_tree().current_scene
		if mapa.has_method("finalizar_corrida"):
			mapa.finalizar_corrida(self)

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
		rotation = lerp_angle(rotation, velocity.angle(), delta * 8.0)
		
	# Aplica o movimento final do frame
	move_and_slide()
