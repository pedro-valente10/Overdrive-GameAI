extends Node2D

@onready var som_botao: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	$CanvasLayer/Control/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CanvasLayer/Control/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	som_botao.play()
	get_tree().change_scene_to_file("res://scenes/choose_map.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_quit_button_mouse_entered() -> void:
	pass # Replace with function body.
