extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/Control/VBoxContainer/Map1Button.pressed.connect(_on_map1_pressed)

func _on_map1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/choose_car.tscn")
