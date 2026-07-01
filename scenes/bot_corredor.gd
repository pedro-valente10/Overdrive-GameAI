extends PathFollow2D

# Velocidade do bot.
@export var speed: float = 200.0

func _process(delta):
	# progress é uma propriedade nativa do PathFollow2D. 
	# Ela avança o objeto ao longo da linha desenhada
	progress += speed * delta
