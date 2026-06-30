class_name BTSistemaAceleracao extends BTNode

# Simula inércia e aceleração gradual (mais realista que instantânea)

# --- PARÂMETROS DE ACELERAÇÃO ---
@export var aceleracao_rate: float = 800.0   # quanto acelera por segundo
@export var frenagem_rate: float = 600.0     # quanto frena por segundo
@export var frenagem_emergencial_rate: float = 1200.0  # frena MUITO rápido

# --- VARIÁVEIS INTERNAS ---
var velocidade_atual: float = 0.0  # velocidade escalar (não vetorial)

func aplicar_aceleracao(bot: CharacterBody2D, 
						velocidade_alvo: float, 
						delta: float) -> void:
	"""
	Acelera/freia suavemente até a velocidade alvo.
	Simula inércia realista.
	"""
	
	var diferenca = velocidade_alvo - velocidade_atual
	
	if diferenca > 0:
		# ACELERANDO
		velocidade_atual += aceleracao_rate * delta
		velocidade_atual = min(velocidade_atual, velocidade_alvo)
	else:
		# FREANDO NORMAL
		velocidade_atual -= frenagem_rate * delta
		velocidade_atual = max(velocidade_atual, velocidade_alvo)
	
	velocidade_atual = max(0.0, velocidade_atual)

func aplicar_frenagem_emergencial(bot: CharacterBody2D, delta: float) -> void:
	"""
	Frena MUITO rápido quando detecta obstáculo à frente.
	"""
	velocidade_atual -= frenagem_emergencial_rate * delta
	velocidade_atual = max(0.0, velocidade_atual)

func obter_velocidade_atual() -> float:
	return velocidade_atual

func resetar_velocidade() -> void:
	velocidade_atual = 0.0

func tick(bot: CharacterBody2D, delta: float) -> int:
	return Status.FAILURE
