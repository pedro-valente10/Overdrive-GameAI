extends Area2D

const VOLTAS_PARA_VENCER = 2

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
@onready var grupo_checkpoints = get_node("../Checkpoints") 

func _ready():
	if label_hud:
		label_hud.text = "Laps: 1"
		
	if grupo_checkpoints:
		total_de_checkpoints = grupo_checkpoints.get_child_count()
		
		for cp in grupo_checkpoints.get_children():
			cp.body_entered.connect(_on_qualquer_checkpoint_entered.bind(cp))
			
		print("Sistema de corrida iniciado. Total de Checkpoints na pista: ", total_de_checkpoints)

func _on_qualquer_checkpoint_entered(body, cp_node):
	if body.name == "player":
		if not checkpoints_player.has(cp_node):
			checkpoints_player.append(cp_node)
			print("Player validou um Checkpoint! (", checkpoints_player.size(), "/", total_de_checkpoints, ")")
			
	elif "Bot" in body.name or body.name == "CorpoDoBot":
		if not checkpoints_bot.has(cp_node):
			checkpoints_bot.append(cp_node)

func _on_body_entered(body):
	# Garante que o método exista antes de chamar para evitar crash
	if body.is_in_group("corredores") and body.has_method("completou_uma_volta"):
		body.completou_uma_volta()
		
	# --- LÓGICA DO PLAYER ---
	if body.name == "player" and pode_contar_player:
		pode_contar_player = false
		
		if primeira_passagem_player:
			primeira_passagem_player = false
			await get_tree().create_timer(2.0).timeout
			pode_contar_player = true
			return
		
		if checkpoints_player.size() >= total_de_checkpoints:
			voltas_player += 1
			if label_hud:
				label_hud.text = "Laps: " + str(voltas_player)
			
			checkpoints_player.clear() 
			print("Volta legítima! Passou para a volta: ", voltas_player)
			
			if voltas_player >= VOLTAS_PARA_VENCER:
				avisar_gerenciador_sobre_vitoria(body)
		else:
			print("Trapaça detectada! Faltam checkpoints. Coletados apenas: ", checkpoints_player.size())
		
		await get_tree().create_timer(2.0).timeout
		pode_contar_player = true

	# --- LÓGICA DO BOT ---
	elif ("Bot" in body.name or body.name == "CorpoDoBot") and pode_contar_bot:
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
				avisar_gerenciador_sobre_vitoria(body)
				
		await get_tree().create_timer(2.0).timeout
		pode_contar_bot = true


func avisar_gerenciador_sobre_vitoria(vencedor):
	# Procura a função finalizar_corrida no nó pai (o map1)
	var map = get_parent()
	if map and map.has_method("finalizar_corrida"):
		map.finalizar_corrida(vencedor)
	else:
		print("ERRO: O nó pai da Linha de Chegada não possui a função 'finalizar_corrida()'")
