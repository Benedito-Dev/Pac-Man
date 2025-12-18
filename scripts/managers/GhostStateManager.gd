extends Node

# Estados globais dos fantasmas
enum GlobalGhostState {
	SCATTER,
	CHASE,
	RUN_AWAY
}

# Estado atual global
var current_global_state: GlobalGhostState = GlobalGhostState.SCATTER

# Timers
@onready var scatter_timer: Timer = Timer.new()

# Sinais para comunicar com fantasmas
signal state_changed_to_scatter
signal state_changed_to_chase
signal power_pellet_eaten

func _ready():
	# Configurar timer de scatter (8 segundos)
	add_child(scatter_timer)
	scatter_timer.wait_time = 8.0
	scatter_timer.timeout.connect(_on_scatter_timer_timeout)

func start_scatter_mode():
	current_global_state = GlobalGhostState.SCATTER
	scatter_timer.start()
	state_changed_to_scatter.emit()
	print("🚶 Modo SCATTER ativado - 8 segundos")

func start_chase_mode():
	current_global_state = GlobalGhostState.CHASE
	scatter_timer.stop()
	state_changed_to_chase.emit()
	print("🎯 Modo CHASE ativado")

func trigger_run_away():
	current_global_state = GlobalGhostState.RUN_AWAY
	power_pellet_eaten.emit()
	print("😱 Modo RUN_AWAY ativado")

func _on_scatter_timer_timeout():
	start_chase_mode()
