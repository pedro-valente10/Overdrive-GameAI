extends Node2D

@onready var som_botao: AudioStreamPlayer = $AudioStreamPlayer
@onready var som_motor: AudioStreamPlayer = $SomMotor

var dot_count : int = 0


func _ready() -> void:
	$CanvasLayer/Control/TimerLoading.stop()
	$CanvasLayer/Control/LabelLoading.visible = false
	
	$CanvasLayer/Control/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CanvasLayer/Control/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	$CanvasLayer/Control/TimerLoading.timeout.connect(_on_timer_loading_timeout)

func _on_play_pressed() -> void:
	som_botao.play() 
	som_motor.play() 
	
	$CanvasLayer/Control/VBoxContainer/PlayButton.disabled = true
	$CanvasLayer/Control/LabelLoading.visible = true
	$CanvasLayer/Control/TimerLoading.start()
	
	
	await get_tree().create_timer(3.5).timeout
	get_tree().change_scene_to_file("res://scenes/choose_map.tscn")

func _on_timer_loading_timeout():
	dot_count += 1
	if dot_count > 3:
		dot_count = 0
	
	match dot_count:
		0: $CanvasLayer/Control/LabelLoading.text = "LOADING"
		1: $CanvasLayer/Control/LabelLoading.text = "LOADING."
		2: $CanvasLayer/Control/LabelLoading.text = "LOADING.."
		3: $CanvasLayer/Control/LabelLoading.text = "LOADING..."

func _on_quit_pressed() -> void:
	get_tree().quit()
