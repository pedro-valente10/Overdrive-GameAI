extends Node2D

@onready var label_titulo = $ResultadoLabel
@onready var label_posicao = $PosicaoLabel

func _ready():
	modulate = Color(0, 0, 0, 1)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1.0)
	$HBoxContainer/RestartButton.pressed.connect(_on_play_pressed)
	$HBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	# Configura os textos baseados no Autoload
	if DadosCorrida.jogador_venceu:
		label_titulo.text = "VITÓRIA!"
		label_titulo.modulate = Color.GREEN
		label_posicao.text = "Você terminou em 1º lugar! Campeão!"
	else:
		label_titulo.text = "DERROTA!"
		label_titulo.modulate = Color.RED
		label_posicao.text = "Você terminou em " + str(DadosCorrida.posicao_final) + "º lugar."

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/choose_map.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
