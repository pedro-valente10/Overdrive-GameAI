class_name BTSequence extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	for filho in get_children():
		var status = filho.tick(bot, delta)
		if status != Status.SUCCESS:
			return status
			
	return Status.SUCCESS
