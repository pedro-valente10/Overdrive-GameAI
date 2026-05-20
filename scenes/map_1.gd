extends Node2D

@onready var contagem_label = $CanvasLayer/ContadorLabel # Certifique-se de que o caminho está correto

func _ready():
	# 1. Garante que ninguém corre assim que o mapa carrega
	bloquear_todos_os_corredores()
	# 2. Inicia a contagem regressiva
	iniciar_contagem()

func iniciar_contagem():
	contagem_label.text = "3"
	await get_tree().create_timer(1.0).timeout
	
	contagem_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	
	contagem_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	
	contagem_label.text = "CORRA!"
	# 3. Libera todo mundo que está no grupo "corredores"
	liberar_todos_os_corredores()
	
	# Espera mais um segundo e some com o texto da tela
	await get_tree().create_timer(1.0).timeout
	contagem_label.visible = false

func bloquear_todos_os_corredores():
	# Dispara a função 'definir_pode_correr(false)' em absolutamente todos os nós do grupo
	get_tree().call_group("corredores", "definir_pode_correr", false)

func liberar_todos_os_corredores():
	# Dispara a função 'definir_pode_correr(true)' para todo mundo do grupo jogar
	get_tree().call_group("corredores", "definir_pode_correr", true)
