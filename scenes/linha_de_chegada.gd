extends Area2D

# Configuração do Jogo
const VOLTAS_PARA_VENCER = 3 

var voltas_player = 1
var voltas_bot = 1

# Travas normais de tempo
var pode_contar_player = true
var pode_contar_bot = true
var primeira_passagem_player = true
var primeira_passagem_bot = true

# --- NOVAS TRAVAS ANTI-TRAPAÇA ---
var checkpoint_player = false
var checkpoint_bot = false

# Referências dos Nós de Interface
@onready var label_hud = get_node("../CanvasLayer/Label")
@onready var painel_final = get_node("../CanvasLayer/PainelFinal")
@onready var resultado_text = get_node("../CanvasLayer/PainelFinal/ResultadoLabel")

func _ready():
	if label_hud:
		label_hud.text = "Voltas: 1"

func _on_body_entered(body):
	# --- LÓGICA DO JOGADOR ---
	if body.name == "CharacterBody2D" and pode_contar_player:
		pode_contar_player = false
		
		# Ignora o primeiro gatilho do spawn de largada
		if primeira_passagem_player:
			primeira_passagem_player = false
			await get_tree().create_timer(2.0).timeout
			pode_contar_player = true
			return
		
		# SÓ COMPUTAR VOLTA SE DETECTOU O CHECKPOINT DO OUTRO LADO
		if checkpoint_player:
			voltas_player += 1
			if label_hud:
				label_hud.text = "Voltas: " + str(voltas_player)
			
			# Reseta a trava: agora ele precisa ir lá do outro lado de novo
			checkpoint_player = false
			print("Volta válida! Passou para a volta: ", voltas_player)
			
			if voltas_player >= VOLTAS_PARA_VENCER:
				finalizar_jogo("VITÓRIA")
		else:
			print("Tentativa de trapaça ou volta incompleta detectada para o Jogador!")
		
		await get_tree().create_timer(2.0).timeout
		pode_contar_player = true

	# --- LÓGICA DO BOT ---
	elif body.name == "CorpoDoBot" and pode_contar_bot:
		pode_contar_bot = false
		
		if primeira_passagem_bot:
			primeira_passagem_bot = false
			print("Bot cruzou a largada!")
			await get_tree().create_timer(2.0).timeout
			pode_contar_bot = true
			return
		
		# SÓ COMPUTAR VOLTA DO BOT SE ELE PASSOU PELO CHECKPOINT
		if checkpoint_bot:
			voltas_bot += 1
			print("Bot completou a volta de forma legítima! Volta: ", voltas_bot)
			
			checkpoint_bot = false # Reseta a trava do bot
			
			if voltas_bot >= VOLTAS_PARA_VENCER:
				finalizar_jogo("DERROTA")
		else:
			print("Bot tentou trapacear ou foi teleportado!")
			
		await get_tree().create_timer(2.0).timeout
		pode_contar_bot = true

# --- SINAL DO CHECKPOINT INVISÍVEL (METADE DA PISTA) ---
func _on_checkpoint_body_entered(body):
	if body.name == "CharacterBody2D":
		checkpoint_player = true
		print("Jogador validou o Checkpoint! Linha de chegada liberada.")
	elif body.name == "CorpoDoBot":
		checkpoint_bot = true
		print("Bot validou o Checkpoint!")

func finalizar_jogo(mensagem):
	if painel_final and resultado_text:
		painel_final.visible = true
		resultado_text.text = mensagem
	get_tree().paused = true
