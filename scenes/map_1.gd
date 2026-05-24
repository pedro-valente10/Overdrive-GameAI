extends Node2D

@onready var contagem_label = $CanvasLayer/ContadorLabel

func _ready():
	# 1. A SOLUÇÃO MÁGICA: Garante que o jogo não está pausado de uma corrida anterior
	get_tree().paused = false
	
	# Garante que o label vai aparecer na tela
	if contagem_label:
		contagem_label.show()
	else:
		print("ERRO FATAL: O Godot não achou o ContadorLabel! Verifique o caminho.")
	
	bloquear_todos_os_corredores()
	iniciar_contagem()

func iniciar_contagem():
	print("Contagem: 3")
	contagem_label.text = "3"
	await get_tree().create_timer(1.0).timeout
	
	print("Contagem: 2")
	contagem_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	
	print("Contagem: 1")
	contagem_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	
	print("Contagem: DRIVE!")
	contagem_label.text = "DRIVE!"
	
	liberar_todos_os_corredores()
	
	await get_tree().create_timer(1.0).timeout
	contagem_label.visible = false
	print("Contagem: Texto escondido.")

func bloquear_todos_os_corredores():
	print("Bloqueando carros...")
	get_tree().call_group("corredores", "definir_pode_correr", false)

func liberar_todos_os_corredores():
	print("Carros liberados!")
	get_tree().call_group("corredores", "definir_pode_correr", true)

# Função Ponte para o Gerenciador
func finalizar_corrida(vencedor):
	if $GerenciadorCorrida:
		$GerenciadorCorrida.finalizar_corrida(vencedor)
