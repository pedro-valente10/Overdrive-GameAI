extends Area2D

var voltas = 1
var pode_contar = true
var primeira_passagem = true

@onready var display_texto = get_node("../CanvasLayer/Label")

func _ready():
	if display_texto:
		display_texto.text = "Voltas: 1"

func _on_body_entered(body):
	if body.name == "CharacterBody2D" and pode_contar:
		pode_contar = false 
		
		if primeira_passagem:
			primeira_passagem = false
			print("Largada detectada! Mantendo em Volta 1.")
			
			# Reduzido para 2 segundos!
			await get_tree().create_timer(2.0).timeout
			pode_contar = true
			return 
		
		voltas += 1
		
		if display_texto:
			display_texto.text = "Voltas: " + str(voltas)
		
		print("Volta completada! Indo para a volta: ", voltas)
		
		# Reduzido para 2 segundos! A trava desliga rapidinho agora.
		await get_tree().create_timer(2.0).timeout
		pode_contar = true
