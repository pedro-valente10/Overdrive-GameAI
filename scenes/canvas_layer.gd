extends CanvasLayer

@onready var player_a: VideoStreamPlayer = $VideoPlayerA
@onready var player_b: VideoStreamPlayer = $VideoPlayerB

# Caminhos dos vídeos (ajuste para a sua pasta real)
const VIDEO_INICIAL = "res://videos/OVERDRIVE-opening.ogv"
const VIDEO_LOOP = "res://videos/OVERDRIVE-opening-scene-loop.ogv"
const VIDEO_RESPOSTA = "res://videos/OVERDRIVE-opening.ogv"

enum Estado { INICIAL, LOOP_ESPERA, RESPOSTA }
var estado_atual: Estado = Estado.INICIAL

# Controla qual player está ativo no momento (true = A, false = B)
var usando_player_a: bool = true

func _ready() -> void:
	# Conecta os sinais de forma segura
	if player_a and player_b:
		player_a.finished.connect(_on_video_finished)
		player_b.finished.connect(_on_video_finished)
		
		# Prepara o primeiro vídeo no Player A e esconde o B
		player_a.stream = load(VIDEO_INICIAL)
		player_a.visible = true
		player_b.visible = false
		player_a.play()
		
		# Já deixa o vídeo de loop carregando no Player B em segundo plano!
		player_b.stream = load(VIDEO_LOOP)
		player_b.stop()
	else:
		push_error("Os nós VideoPlayerA ou VideoPlayerB não foram encontrados como filhos do CanvasLayer!")

func _input(event: InputEvent) -> void:
	if estado_atual == Estado.LOOP_ESPERA:
		if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER):
			estado_atual = Estado.RESPOSTA
			tocar_transicao(VIDEO_RESPOSTA)

func tocar_transicao(caminho: String) -> void:
	var player_atual = player_a if usando_player_a else player_b
	var player_proximo = player_b if usando_player_a else player_a
	
	player_proximo.stream = load(caminho)
	player_proximo.play()
	
	player_proximo.visible = true
	player_atual.visible = false
	player_atual.stop()
	
	usando_player_a = !usando_player_a

func _on_video_finished() -> void:
	match estado_atual:
		Estado.INICIAL:
			estado_atual = Estado.LOOP_ESPERA
			tocar_transicao(VIDEO_LOOP)
			
		Estado.LOOP_ESPERA:
			var player_ativo = player_a if usando_player_a else player_b
			player_ativo.play()
			
		Estado.RESPOSTA:
			estado_atual = Estado.LOOP_ESPERA
			tocar_transicao(VIDEO_LOOP)
