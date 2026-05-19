extends Node2D

@onready var som_botao: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	$CanvasLayer/Control/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CanvasLayer/Control/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	som_botao.play()
	await som_botao.finished
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://scenes/choose_map.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
