extends CharacterBody2D
class_name GhostBase

# Estados individuais
enum GhostState {
	STARTING_AT_HOME,
	SCATTER,
	CHASE,
	RUN_AWAY,
	EATEN
}

# Variáveis principais
var current_state: GhostState = GhostState.STARTING_AT_HOME
@export var movement_targets: MovementTargets
@export var speed: float = 120.0
@export var target: CharacterBody2D

# Componentes
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Índices para patrulha
var current_scatter_index: int = 0
var current_home_index: int = 0

# Timers individuais
var at_home_timer: Timer
var run_away_timer: Timer
var chase_update_timer: Timer  # ← NOVO TIMER

func _ready():
	# Criar timers
	at_home_timer = Timer.new()
	at_home_timer.wait_time = 3.0
	at_home_timer.one_shot = true 
	at_home_timer.timeout.connect(_on_at_home_timeout)
	add_child(at_home_timer)
	
	run_away_timer = Timer.new()
	add_child(run_away_timer)
	
	# Timer para atualizar posição do Pacman a cada 0.1s
	chase_update_timer = Timer.new()
	chase_update_timer.wait_time = 0.1
	chase_update_timer.timeout.connect(_on_chase_update)
	add_child(chase_update_timer)
	
	# Conectar sinais
	GhostStateManager.state_changed_to_scatter.connect(_on_global_scatter)
	GhostStateManager.state_changed_to_chase.connect(_on_global_chase)
	GhostStateManager.power_pellet_eaten.connect(_on_power_pellet_eaten)
	nav_agent.target_reached.connect(_on_target_reached)
	
	# Iniciar na base (com delay)
	call_deferred("start_at_home")

func _physics_process(delta):
	var distance = global_position.distance_to(nav_agent.target_position)
	if distance < 5.0 and current_state != GhostState.CHASE:
		_on_target_reached()
	if nav_agent.is_navigation_finished():
		return
		
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = direction * speed
	move_and_slide()

# Estados individuais
func start_at_home():
	current_state = GhostState.STARTING_AT_HOME
	if movement_targets and movement_targets.at_home_targets.size() > 0:
		nav_agent.target_position = movement_targets.at_home_targets[current_home_index]
		at_home_timer.start()

func scatter():
	chase_update_timer.stop()  # Parar atualizações
	if current_state == GhostState.EATEN:
		return
	current_state = GhostState.SCATTER
	if movement_targets and movement_targets.scatter_targets.size() > 0:
		nav_agent.target_position = movement_targets.scatter_targets[current_scatter_index]

func chase():
	if current_state == GhostState.EATEN:
		return
	current_state = GhostState.CHASE
	
	# INICIAR o timer de atualização
	chase_update_timer.start()
	
	if target:
		nav_agent.target_position = calculate_chase_target()

func run_away():
	current_state = GhostState.RUN_AWAY

func get_eaten():
	current_state = GhostState.EATEN
	if movement_targets and movement_targets.at_home_targets.size() > 0:
		nav_agent.target_position = movement_targets.at_home_targets[0]

# Método para override nos filhos
func calculate_chase_target() -> Vector2:
	return target.global_position if target else global_position

# Callbacks
func _on_at_home_timeout():
	GhostStateManager.start_scatter_mode()
	print("🏠 Saiu da base, entrando em SCATTER")

func _on_target_reached():
	print("🔔 target_reached chamado! Estado: ", current_state)
	match current_state:
		GhostState.STARTING_AT_HOME:
			current_home_index = 1 if current_home_index == 0 else 0
			nav_agent.target_position = movement_targets.at_home_targets[current_home_index]
		GhostState.SCATTER:
			current_scatter_index = (current_scatter_index + 1) % movement_targets.scatter_targets.size()
			nav_agent.target_position = movement_targets.scatter_targets[current_scatter_index]

func _on_chase_update():
	if current_state == GhostState.CHASE and target:
		nav_agent.target_position = calculate_chase_target()

# Sinais do StateManager
func _on_global_scatter():
	scatter()

func _on_global_chase():
	chase()

func _on_power_pellet_eaten():
	run_away()
