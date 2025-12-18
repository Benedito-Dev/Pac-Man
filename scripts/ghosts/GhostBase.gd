extends CharacterBody2D
class_name GhostBase

# Estados individuais (incluem os que faltavam!)
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
@export var target: CharacterBody2D  # Referência ao Pacman

# Componentes
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Índices para patrulha
var current_scatter_index: int = 0
var current_home_index: int = 0

# Timers individuais
var at_home_timer: Timer
var run_away_timer: Timer

func _ready():
	# Criar timers
	at_home_timer = Timer.new()
	run_away_timer = Timer.new()
	add_child(at_home_timer)
	add_child(run_away_timer)
	
	# Conectar sinais do StateManager
	GhostStateManager.state_changed_to_scatter.connect(_on_global_scatter)
	GhostStateManager.state_changed_to_chase.connect(_on_global_chase)
	GhostStateManager.power_pellet_eaten.connect(_on_power_pellet_eaten)
	
	# Iniciar na base
	start_at_home()

func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		return
		
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = direction * speed
	move_and_slide()

# Estados individuais
func start_at_home():
	current_state = GhostState.STARTING_AT_HOME
	nav_agent.target_position = movement_targets.at_home_targets[current_home_index]
	at_home_timer.start()

func scatter():
	if current_state == GhostState.EATEN:
		return  # Não muda se está morto
	current_state = GhostState.SCATTER
	nav_agent.target_position = movement_targets.scatter_targets[current_scatter_index]

func chase():
	if current_state == GhostState.EATEN:
		return  # Não muda se está morto
	current_state = GhostState.CHASE
	nav_agent.target_position = target.global_position

func run_away():
	current_state = GhostState.RUN_AWAY
	# Lógica de fuga será implementada depois

func get_eaten():
	current_state = GhostState.EATEN
	nav_agent.target_position = movement_targets.at_home_targets[0]

# Sinais do StateManager
func _on_global_scatter():
	scatter()

func _on_global_chase():
	chase()

func _on_power_pellet_eaten():
	run_away()
