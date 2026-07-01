extends Node2D

# Alteramos o som_botao para AudioStreamPlayer (sem o 2D)
@onready var som_botao: AudioStreamPlayer = $AudioStreamPlayer
@onready var som_motor: AudioStreamPlayer = $SomMotor 

func _ready() -> void:
	$CanvasLayer/Control/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CanvasLayer/Control/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	# Toca os sons
	som_botao.play() 
	som_motor.play() 
	
	# Desativa o botão para evitar cliques duplos
	$CanvasLayer/Control/VBoxContainer/PlayButton.disabled = true
	
	# Aguarda 1.5 segundos para o jogador ouvir o ronco do motor
	await get_tree().create_timer(3.5).timeout
	
	# Só depois que o tempo acaba, ele troca de cena
	get_tree().change_scene_to_file("res://scenes/choose_map.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
