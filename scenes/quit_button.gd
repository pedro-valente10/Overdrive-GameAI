extends Button

@onready var anim_player = $AnimationPlayer

func _on_mouse_entered():
	anim_player.play("hover_in")

func _on_mouse_exited():
	anim_player.play("hover_out")
