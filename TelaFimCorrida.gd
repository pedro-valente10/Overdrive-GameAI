extends Node2D

@onready var label_titulo = $CanvasLayer/ResultadoLabel
@onready var label_posicao = $CanvasLayer/PosicaoLabel

func _ready():
	modulate = Color(0, 0, 0, 1)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(10, 10, 10, 10), 1.0)
	$CanvasLayer/HBoxContainer/RestartButton.pressed.connect(_on_play_pressed)
	$CanvasLayer/HBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	# Configura os textos baseados no Autoload
	if DadosCorrida.jogador_venceu:
		label_titulo.text = "VICTORY"
		label_titulo.modulate = Color.GREEN
		label_posicao.text = "You finished in 1º place! Congratulations!"
	else:
		label_titulo.text = "GAME OVER"
		label_titulo.modulate = Color.RED
		label_posicao.text = "You finished in " + str(DadosCorrida.posicao_final) + "º place"

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/choose_map.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
