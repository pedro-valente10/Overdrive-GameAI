extends Node2D

@onready var contagem_label = $CanvasLayer/RelogioInicial
# Pode remover o ponto_de_partida se não for usar para mais nada

func _ready():
	# Removeu a função antiga que causava o erro
	get_tree().paused = false
	
	if contagem_label:
		contagem_label.show()
	
	bloquear_todos_os_corredores()
	iniciar_contagem()

# A função _carregar_carro_jogador foi removida daqui, 
# pois agora o próprio nó do Player cuida do seu visual usando o DadosCorrida.carro_escolhido_id

func iniciar_contagem():
	await get_tree().create_timer(2.0).timeout

	get_tree().call_group("corredores", "sumir_seta")

	var primeiro_corredor = get_tree().get_first_node_in_group("corredores")
	if primeiro_corredor and primeiro_corredor.has_method("sumir_seta"):
		var tween_seta = primeiro_corredor.sumir_seta()
		if tween_seta:
			await tween_seta.finished

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


func _on_atrito_zebra_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
