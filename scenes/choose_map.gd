extends Node2D


func _ready() -> void:
	$CanvasLayer/Control/VBoxContainer/Map1Button.pressed.connect(_on_map1_pressed)
	if not MusicaGlobal.playing:
		MusicaGlobal.play()

func _on_map1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/choose_car.tscn")
