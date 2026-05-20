class_name BTCondObstaculo extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	if bot.sensor_frente.is_colliding():
		return Status.SUCCESS # Sim, tem obstáculo! Deu certo a verificação.
	return Status.FAILURE # Caminho livre.
