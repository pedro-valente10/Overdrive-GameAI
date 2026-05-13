extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/Control/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CanvasLayer/Control/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/choose_map.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
