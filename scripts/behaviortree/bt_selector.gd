class_name BTSelector extends BTNode

func tick(bot: CharacterBody2D, delta: float) -> int:
	# O Seletor varre os filhos da esquerda pra direita (de cima para baixo na árvore)
	for filho in get_children():
		var status = filho.tick(bot, delta)
		
		# Se um filho retornar SUCCESS (ex: desviou) ou RUNNING, a árvore PARA aqui.
		# Isso impede que o CorrerNormal seja executado por cima do Desviar!
		if status != Status.FAILURE:
			return status
			
	# Se todas as opções falharem, retorna falha
	return Status.FAILURE
