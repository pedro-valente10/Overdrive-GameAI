extends Area2D

const VOLTAS_PARA_VENCER = 6 

var voltas_player = 1
var voltas_bot = 1

var pode_contar_player = true
var pode_contar_bot = true
var primeira_passagem_player = true
var primeira_passagem_bot = true


var checkpoints_player = []
var checkpoints_bot = []    
var total_de_checkpoints = 0

@onready var label_hud = get_node("../CanvasLayer/Label")
@onready var painel_final = get_node("../CanvasLayer/PainelFinal")
@onready var resultado_text = get_node("../CanvasLayer/PainelFinal/ResultadoLabel")


@onready var grupo_checkpoints = get_node("../Checkpoints") 

func _ready():
	if label_hud:
		label_hud.text = "Voltas: 1"
		

	if grupo_checkpoints:
		total_de_checkpoints = grupo_checkpoints.get_child_count()
		
		for cp in grupo_checkpoints.get_children():
			cp.body_entered.connect(_on_qualquer_checkpoint_entered.bind(cp))
			
		print("Sistema de corrida iniciado. Total de Checkpoints na pista: ", total_de_checkpoints)


func _on_qualquer_checkpoint_entered(body, cp_node):
	if body.name == "CharacterBody2D":
		if not checkpoints_player.has(cp_node):
			checkpoints_player.append(cp_node)
			print("Player validou um Checkpoint! (", checkpoints_player.size(), "/", total_de_checkpoints, ")")
			
	elif body.name == "CorpoDoBot":
		if not checkpoints_bot.has(cp_node):
			checkpoints_bot.append(cp_node)

func _on_body_entered(body):
	if body.is_in_group("corredores"):
		body.completou_uma_volta()
	if body.name == "CharacterBody2D" and pode_contar_player:
		pode_contar_player = false
		
		if primeira_passagem_player:
			primeira_passagem_player = false
			await get_tree().create_timer(2.0).timeout
			pode_contar_player = true
			return
		

		if checkpoints_player.size() >= total_de_checkpoints:
			voltas_player += 1
			if label_hud:
				label_hud.text = "Voltas: " + str(voltas_player)
			

			checkpoints_player.clear() 
			print("Volta legítima! Passou para a volta: ", voltas_player)
			
			if voltas_player >= VOLTAS_PARA_VENCER:
				finalizar_jogo("VITÓRIA")
		else:
			print("Trapaça detectada! Faltam checkpoints. Coletados apenas: ", checkpoints_player.size())
		
		await get_tree().create_timer(2.0).timeout
		pode_contar_player = true


	elif body.name == "CorpoDoBot" and pode_contar_bot:
		pode_contar_bot = false
		
		if primeira_passagem_bot:
			primeira_passagem_bot = false
			await get_tree().create_timer(2.0).timeout
			pode_contar_bot = true
			return
		

		if checkpoints_bot.size() >= total_de_checkpoints:
			voltas_bot += 1
			checkpoints_bot.clear() 
			print("Bot completou volta legítima! Volta: ", voltas_bot)
			
			if voltas_bot >= VOLTAS_PARA_VENCER:
				finalizar_jogo("DERROTA")
				
		await get_tree().create_timer(2.0).timeout
		pode_contar_bot = true

func finalizar_jogo(mensagem):
	if painel_final and resultado_text:
		painel_final.visible = true
		resultado_text.text = mensagem
	get_tree().paused = true
