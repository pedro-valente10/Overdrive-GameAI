class_name BTSelector extends BTNode

# Roda os filhos. Se o primeiro falhar, tenta o segundo. 
# Se UM der SUCCESS ou RUNNING, ele para e retorna isso.
func tick(bot: CharacterBody2D, delta: float) -> int:
	for child in get_children():
		var result = child.tick(bot, delta)
		if result != Status.FAILURE:
			return result # Pode ser SUCCESS ou RUNNING
			
	return Status.FAILURE
