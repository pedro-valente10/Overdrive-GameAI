class_name BTSelector extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	for filho in get_children():
		var status = filho.tick(bot, delta)
		if status != Status.FAILURE:
			return status
			
	return Status.FAILURE
