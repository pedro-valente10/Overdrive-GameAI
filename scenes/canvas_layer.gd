extends CanvasLayer

func _ready() -> void:
	var fundo := ColorRect.new()

	fundo.color = Color(0.97, 0.97, 0.95)
	
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo.show_behind_parent = true
	
	add_child(fundo)
	
	move_child(fundo, 0)
