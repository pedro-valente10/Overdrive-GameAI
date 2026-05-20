class_name BTNode extends Node

# Os 3 estados universais de uma Behavior Tree
enum Status { SUCCESS, FAILURE, RUNNING }

# Função que será sobrescrita pelos filhos. 
# Recebe o 'bot' para podermos ler a velocidade e os raycasts dele.
func tick(bot: CharacterBody2D, delta: float) -> int:
	return Status.FAILURE
