extends CharacterBody2D

var pode_correr: bool = false

# O @export permite que você mude esses valores direto no Inspector (lado direito da tela) sem precisar mexer no código de novo!
@export var max_speed = 400.0
@export var acceleration = 1500.0
@export var friction = 800.0
@export var steering_speed = 3.5
var speed_multiplier = 1.0

func definir_pode_correr(status: bool):
	pode_correr = status

func _physics_process(delta):
	if not pode_correr: 
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var turn_input = Input.get_axis("ui_left", "ui_right")
	var drive_input = Input.get_axis("ui_up", "ui_down")

	if velocity.length() > 5:
		var direction_modifier = -1 if drive_input > 0 else 1
		rotation += turn_input * steering_speed * delta * direction_modifier
 
	var current_max_speed = max_speed * speed_multiplier
	
	
	
	if drive_input != 0:
		# Acelera na direção que está apontando
		velocity += (transform.y * drive_input) * acceleration * delta
		# Impede que passe da velocidade máxima
		velocity = velocity.limit_length(current_max_speed)
	else:
		# Se soltou o botão, vai parando aos poucos (fricção)
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# 4. Executa o movimento e lida com as colisões na pista
	move_and_slide()


func _on_atrito_zebra_body_entered(body: Node2D) -> void:
	if body == self: # Se for o meu carro entrando
		speed_multiplier = 0.4 # Reduz a velocidade para 40% (gera o efeito de atrito)


func _on_atrito_zebra_body_exited(body: Node2D) -> void:
	if body == self:
		speed_multiplier = 1.0 # Volta ao normal quando sai da zebra
