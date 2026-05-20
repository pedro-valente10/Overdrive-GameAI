extends Node2D

@onready var contador_label = $CanvasLayer/ContadorLabel
@onready var contador_timer = $CanvasLayer/ContadorTimer
@onready var carro = $CharacterBody2D #carro do jogador
@onready var bots = $BotSteering

var tempo_restante = 3

func _ready():
	# 1. Bloqueia o movimento do carro assim que a cena carrega
	carro.pode_correr = false
	
	# 2. Configura o texto inicial e inicia o timer de 1 segundo
	contador_label.text = str(tempo_restante)
	contador_timer.start()
	
	# 3. Conecta o sinal do timer via código (ou você pode fazer pelo nó de Sinais)
	contador_timer.timeout.connect(_on_contador_timer_timeout)

func _on_contador_timer_timeout():
	tempo_restante -= 1
	
	if tempo_restante > 0:
		# Ainda está na contagem (2, 1)
		contador_label.text = str(tempo_restante)
		contador_timer.start() # Reinicia o timer para o próximo segundo
	elif tempo_restante == 0:
		contador_label.text = "DRIVE!"
		carro.pode_correr = true # Libera o carro!
		bots.pode_correr = true
		contador_timer.start() # Roda o timer uma última vez para sumir com o texto
	else:
		contador_label.visible = false
