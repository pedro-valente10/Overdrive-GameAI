class_name BTSequence extends BTNode

# Roda os filhos em ordem. Se UM falhar, tudo falha (retorna FAILURE).
# Se todos derem SUCCESS, ele retorna SUCCESS.
func tick(bot: CharacterBody2D, delta: float) -> int:
	for child in get_children():
		var result = child.tick(bot, delta)
		if result != Status.SUCCESS:
			return result # Pode ser FAILURE ou RUNNING
			
	return Status.SUCCESS
