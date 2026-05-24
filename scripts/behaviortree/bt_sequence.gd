class_name BTSequence extends BTNode
# (O nome da classe pode estar diferente, mantenha o seu se precisar)

func tick(bot: CharacterBody2D, delta: float) -> int:
	# Roda todos os filhos em ordem (TemObs -> depois Desviar)
	for filho in get_children():
		var status = filho.tick(bot, delta)
		
		# Se o TemObs falhar (não tem obstáculo), a sequência aborta aqui
		if status != Status.SUCCESS:
			return status
			
	# Se passou por todos (TemObs deu sucesso e Desviar deu sucesso)
	return Status.SUCCESS
