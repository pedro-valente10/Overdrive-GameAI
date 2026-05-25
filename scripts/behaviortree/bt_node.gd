class_name BTNode extends Node

enum Status { SUCCESS, FAILURE, RUNNING }


func tick(bot: CharacterBody2D, delta: float) -> int:
	return Status.FAILURE
