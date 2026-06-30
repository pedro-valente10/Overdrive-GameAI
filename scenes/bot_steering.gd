extends CharacterBody2D

var pode_correr: bool = false

@export var texturas_dos_carros: Array[Texture2D]
@onready var sprite = $Sprite2D

@export var velocidade_maxima = 275.0
@export var forca_curva = 3.0
@export var distancia_alvo = 90.0

@export_group("Personalidade do Piloto")
@export_range(0.5, 2.0) var coragem: float = 1.0 
@export_range(0.5, 2.0) var agressividade_volante: float = 1.0 
@export var multiplicador_tangente: float = 1.2
@export var alcance_visao: float = 220.0

@onready var arvore_comportamento = $BehaviorTree

var lista_waypoints = []
var indice_alvo = 0
var voltas_completadas: int = 0
var max_voltas: int = 6

# --- FÍSICA MECÂNICA AVANÇADA DE CARRO ---
@export_group("Motor e Física Real")
@export var aceleracao = 1000.0 
@export var frenagem = 500.0
@export var atrito_pista = 150.0

@export var velocidade_giro_volante = 6.0 
@export var aderencia_pneu = 3.5 

var velocidade_atual: float = 0.0
var pedal_acelerador: float = 0.0 
var volante: float = 0.0 
var volante_fisico_real: float = 0.0 

# NOVA VARIÁVEL: O tempo que o câmbio leva para engatar a ré
var tempo_tentando_re: float = 0.0 


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
		
	# Zera os comandos mentais da IA
	pedal_acelerador = 0.0
	volante = 0.0
	
	if arvore_comportamento:
		arvore_comportamento.tick(self, delta)
		
	# --- 1. O ATRASO DO VOLANTE ---
	volante_fisico_real = lerp(volante_fisico_real, volante, velocidade_giro_volante * delta)
		
	# --- 2. O MOTOR E A CAIXA DE CÂMBIO ---
	if pedal_acelerador > 0:
		velocidade_atual += aceleracao * pedal_acelerador * delta
		tempo_tentando_re = 0.0
	elif pedal_acelerador < 0:
		if velocidade_atual > 5.0:
			# O carro está indo para frente, então o pedal atua puramente como FREIO
			velocidade_atual += frenagem * pedal_acelerador * delta 
			tempo_tentando_re = 0.0
		else:
			# O carro está parado ou a 0 km/h. A IA quer engatar a ré!
			tempo_tentando_re += delta
			
			if tempo_tentando_re > 0.25:
				# A marcha ré engatou! Acelera o motor para trás (com menos força que para frente)
				velocidade_atual += (aceleracao * 0.4) * pedal_acelerador * delta
			else:
				# Segura o carro completamente freado enquanto a marcha não entra.
				# (ISSO MATA A RÉ DA LARGADA!)
				velocidade_atual = move_toward(velocidade_atual, 0.0, frenagem * delta)
	else:
		velocidade_atual = move_toward(velocidade_atual, 0.0, atrito_pista * delta)
		tempo_tentando_re = 0.0
		
	velocidade_atual = clamp(velocidade_atual, -velocidade_maxima * 0.35, velocidade_maxima)
	
	# --- 3. VIRANDO O EIXO ---
	if abs(velocidade_atual) > 5.0:
		var direcao_movimento = sign(velocidade_atual)
		var velocidade_proporcional = abs(velocidade_atual) / velocidade_maxima
		rotation += volante_fisico_real * forca_curva * direcao_movimento * velocidade_proporcional * delta
		
	# --- 4. OS PNEUS (TRAÇÃO REAL) ---
	var direcao_atual = Vector2.RIGHT.rotated(rotation)
	velocity = velocity.lerp(direcao_atual * velocidade_atual, aderencia_pneu * delta)
	
	move_and_slide()
