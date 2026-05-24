extends Node2D

@onready var contagem_label = $CanvasLayer/ContadorLabel

func _ready():
	get_tree().paused = false
	
	if contagem_label:
		contagem_label.show()
	
	bloquear_todos_os_corredores()
	iniciar_contagem()

func iniciar_contagem():
	contagem_label.text = "3"
	await get_tree().create_timer(1.0).timeout
	
	contagem_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	
	contagem_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	
	contagem_label.text = "DRIVE!"
	liberar_todos_os_corredores()
	
	await get_tree().create_timer(1.0).timeout
	contagem_label.visible = false

func bloquear_todos_os_corredores():
	get_tree().call_group("corredores", "definir_pode_correr", false)

func liberar_todos_os_corredores():
	get_tree().call_group("corredores", "definir_pode_correr", true)

func finalizar_corrida(vencedor):
	if $GerenciadorCorrida:
		$GerenciadorCorrida.finalizar_corrida(vencedor)
