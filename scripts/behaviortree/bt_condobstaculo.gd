class_name BTCondicaoTemObs extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	# Varre TODOS os filhos diretos do bot
	for filho in bot.get_children():
		# Se o filho for um RayCast2D e estiver colidindo...
		if filho is RayCast2D and filho.is_colliding():
			return Status.SUCCESS # Encontrou um obstáculo, passa para o nó Desviar
			
	# Se olhou todos os filhos e nenhum raio bateu...
	return Status.FAILURE # Caminho livre, não precisa desviar
