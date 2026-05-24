class_name BTCondicaoTemObs extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	# find_children busca recursivamente, encontrando RayCast2D dentro de sub-nós
	for filho in bot.find_children("*", "RayCast2D", true, false):
		if filho.is_colliding():
			print("ALERTA! Bati no objeto: ", filho.get_collider().name)
			return Status.SUCCESS
			
	return Status.FAILURE
