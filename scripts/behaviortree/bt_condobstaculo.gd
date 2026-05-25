class_name BTCondicaoTemObs extends BTNode

func tick(bot: CharacterBody2D, _delta: float) -> int:
	for filho in bot.find_children("*", "RayCast2D", true, false):
		if filho.is_colliding():
			print("ALERTA! Bati no objeto: ", filho.get_collider().name)
			return Status.SUCCESS
			
	return Status.FAILURE
