extends PathFollow2D

# Velocidade do bot. Você pode ajustar no Inspector!
@export var speed: float = 200.0

func _process(delta):
	# progress é uma propriedade nativa do PathFollow2D. 
	# Ela avança o objeto ao longo da linha que você desenhou.
	progress += speed * delta
