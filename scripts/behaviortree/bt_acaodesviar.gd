class_name BTAcaoDesviar extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	var ponto_colisao = bot.sensor_frente.get_collision_point()
	var normal_colisao = bot.sensor_frente.get_collision_normal()
	
	var velocidade_fuga = normal_colisao * bot.velocidade_maxima
	var forca_steering = (velocidade_fuga - bot.velocity) * (bot.forca_curva * 2.0) * delta
	
	bot.velocity += forca_steering
	return Status.SUCCESS # Apliquei a força, terminei meu trabalho neste frame.
