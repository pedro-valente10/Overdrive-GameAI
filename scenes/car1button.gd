extends Button

func _ready() -> void:
	self.pressed.connect(_on_car1_pressed)

func _on_car1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map1.tscn")
