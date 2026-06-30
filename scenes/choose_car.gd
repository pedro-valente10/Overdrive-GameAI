extends Node2D

func _ready() -> void:
	$CanvasLayer/Control/VBoxContainer/Car1Button.pressed.connect(func(): _escolher_carro_e_correr(0))
	$CanvasLayer/Control/VBoxContainer/Car2Button.pressed.connect(func(): _escolher_carro_e_correr(1))
	$CanvasLayer/Control/VBoxContainer/Car3Button.pressed.connect(func(): _escolher_carro_e_correr(2))
	$CanvasLayer/Control/VBoxContainer/Car4Button.pressed.connect(func(): _escolher_carro_e_correr(3))

func _escolher_carro_e_correr(id_carro: int) -> void:
	DadosCorrida.carro_escolhido_id = id_carro
	get_tree().change_scene_to_file("res://scenes/map1.tscn")
