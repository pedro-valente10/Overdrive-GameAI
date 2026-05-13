extends CharacterBody2D

# O @export permite que você mude esses valores direto no Inspector (lado direito da tela) sem precisar mexer no código de novo!
@export var max_speed = 400.0
@export var acceleration = 1500.0
@export var friction = 800.0
@export var steering_speed = 3.5

func _physics_process(delta):
	# 1. Pegar as teclas pressionadas (Setas direcionais por padrão)
	# ui_up = -1, ui_down = 1 (O Y no Godot é invertido: para cima é negativo)
	var turn_input = Input.get_axis("ui_left", "ui_right")
	var drive_input = Input.get_axis("ui_up", "ui_down")
	
	# 2. Sistema de Curvas (Só vira se o carro estiver em movimento)
	if velocity.length() > 5:
		# Se estiver dando ré, inverte a curva para o controle ficar natural
		var direction_modifier = -1 if drive_input > 0 else 1
		rotation += turn_input * steering_speed * delta * direction_modifier

	# 3. Aceleração e Fricção
	# O seu sprite aponta para CIMA, então usamos 'transform.y' para saber para onde a "frente" do carro está apontando.
	if drive_input != 0:
		# Acelera na direção que está apontando
		velocity += (transform.y * drive_input) * acceleration * delta
		# Impede que passe da velocidade máxima
		velocity = velocity.limit_length(max_speed)
	else:
		# Se soltou o botão, vai parando aos poucos (fricção)
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# 4. Executa o movimento e lida com as colisões na pista
	move_and_slide()
