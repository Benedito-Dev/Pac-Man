extends Node

# Estados globais dos fantasmas
enum GlobalGhostState {
	SCATTER,
	CHASE,
	RUN_AWAY
}

# Estado atual global
var current_global_state: GlobalGhostState = GlobalGhostState.SCATTER

# Padrão do Level 1
var level_1_pattern = [
	{"mode": "SCATTER", "duration": 7},
	{"mode": "CHASE", "duration": 20},
	{"mode": "SCATTER", "duration": 7},
	{"mode": "CHASE", "duration": 20},
	{"mode": "SCATTER", "duration": 5},
	{"mode": "CHASE", "duration": 20},
	{"mode": "SCATTER", "duration": 5},
	{"mode": "CHASE", "duration": -1}  # -1 = infinito
]
var scatter_timer: Timer  # ← ADICIONAR esta linha

var current_pattern_index: int = 0

# Timers
var power_mode_timer: Timer

# Sinais para comunicar com fantasmas
signal state_changed_to_scatter
signal state_changed_to_chase
signal power_pellet_eaten
signal power_mode_ended

func _ready():
	# Configurar timer dinâmico
	scatter_timer = Timer.new()
	add_child(scatter_timer)
	scatter_timer.timeout.connect(_on_pattern_timer_timeout)  # ← Novo nome
	
	# Timer do power mode (manter igual)
	power_mode_timer = Timer.new()
	power_mode_timer.wait_time = 7.0
	power_mode_timer.one_shot = true
	power_mode_timer.timeout.connect(_on_power_mode_timeout)
	add_child(power_mode_timer)
	
	# Iniciar com o primeiro padrão
	start_pattern_system()

func start_pattern_system():
	current_pattern_index = 0
	start_next_pattern_phase()

func start_next_pattern_phase():
	# Verificar se chegou no final do padrão
	if current_pattern_index >= level_1_pattern.size():
		print("⚠️ Padrão finalizado")
		return
	
	# Pegar fase atual do padrão
	var current_phase = level_1_pattern[current_pattern_index]
	var mode = current_phase["mode"]
	var duration = current_phase["duration"]
	
	# Aplicar o modo
	if mode == "SCATTER":
		current_global_state = GlobalGhostState.SCATTER
		state_changed_to_scatter.emit()
		print("🚶 Modo SCATTER ativado - ", duration, " segundos")
	elif mode == "CHASE":
		current_global_state = GlobalGhostState.CHASE
		state_changed_to_chase.emit()
		print("🎯 Modo CHASE ativado - ", duration, " segundos" if duration > 0 else "INFINITO")
	
	# Configurar timer
	if duration > 0:
		scatter_timer.wait_time = duration
		scatter_timer.start()
	else:
		scatter_timer.stop()  # Infinito, não reinicia
	
	# Incrementar índice para próxima fase
	current_pattern_index += 1

func trigger_run_away():
	current_global_state = GlobalGhostState.RUN_AWAY
	scatter_timer.stop()
	power_mode_timer.start()
	power_pellet_eaten.emit()
	print("😱 Modo RUN_AWAY ativado")

func _on_pattern_timer_timeout():
	start_next_pattern_phase()
	
func _on_power_mode_timeout():
	power_mode_ended.emit()  # Avisar game.gd
	start_pattern_system()
	print("⏰ Power mode terminou")
