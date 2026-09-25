extends Node

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer # Ajuste o caminho se necessário

# Defina os caminhos dos seus vídeos (.ogv)
const VIDEO_INICIAL = "res://videos/intro.ogv"
const VIDEO_LOOP = "res://videos/aguardando_enter.ogv"
const VIDEO_RESPOSTA = "res://videos/reacao_enter.ogv"

enum Estado { INICIAL, LOOP_ESPERA, RESPOSTA }
var estado_atual: Estado = Estado.INICIAL

func _ready() -> void:
	# Conecta o sinal de término do vídeo
	video_player.finished.connect(_on_video_finished)
	
	# Inicia o primeiro vídeo
	tocar_video(VIDEO_INICIAL)

func _input(event: InputEvent) -> void:
	# Só escuta o Enter se estivermos na fase de loop esperando o usuário
	if estado_atual == Estado.LOOP_ESPERA:
		if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER):
			estado_atual = Estado.RESPOSTA
			tocar_video(VIDEO_RESPOSTA)

func tocar_video(caminho: String) -> void:
	var stream = load(caminho)
	if stream:
		video_player.stream = stream
		video_player.play()

func _on_video_finished() -> void:
	match estado_atual:
		Estado.INICIAL:
			# Assim que o primeiro acaba, muda o estado para loop e troca o stream imediatamente
			estado_atual = Estado.LOOP_ESPERA
			tocar_video(VIDEO_LOOP)
			
		Estado.LOOP_ESPERA:
			# Como este vídeo deve ficar em loop infinito aguardando o Enter,
			# assim que ele terminar, chamamos o play() de novo na mesma hora.
			video_player.play()
			
		Estado.RESPOSTA:
			# O que acontece depois que o vídeo do Enter acaba? 
			# Exemplo: voltar para o loop de espera, ou parar.
			estado_atual = Estado.LOOP_ESPERA
			tocar_video(VIDEO_LOOP)
