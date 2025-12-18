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
var power_mode_timer: Timer

# Sinais para comunicar com fantasmas
signal state_changed_to_scatter
signal state_changed_to_chase
signal power_pellet_eaten
signal power_mode_ended

func _ready():
	# Configurar timer de scatter (8 segundos)
	add_child(scatter_timer)
	scatter_timer.wait_time = 8.0
	scatter_timer.timeout.connect(_on_scatter_timer_timeout)
	
	power_mode_timer = Timer.new()
	power_mode_timer.wait_time = 7.0
	power_mode_timer.one_shot = true
	power_mode_timer.timeout.connect(_on_power_mode_timeout)
	add_child(power_mode_timer)

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
	scatter_timer.stop()
	power_mode_timer.start()
	power_pellet_eaten.emit()
	print("😱 Modo RUN_AWAY ativado")

func _on_scatter_timer_timeout():
	start_chase_mode()
	
func _on_power_mode_timeout():
	power_mode_ended.emit()  # Avisar game.gd
	start_chase_mode()  # Voltar para perseguição
	print("⏰ Power mode terminou")
