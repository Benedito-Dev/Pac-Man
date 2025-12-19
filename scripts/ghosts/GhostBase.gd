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
@onready var normal_sprite: Sprite2D = $NormalSprite  
@onready var scare_sprite: Sprite2D = $ScareSprite
@onready var eaten_sprite: Sprite2D = $EatenSprite

# Índices para patrulha
var current_scatter_index: int = 0
var current_home_index: int = 0

# Timers individuais
var at_home_timer: Timer
var chase_update_timer: Timer
var run_away_update_timer: Timer

func _ready():
	# Tempo na Base
	at_home_timer = Timer.new()
	at_home_timer.wait_time = 3.0
	at_home_timer.one_shot = true 
	at_home_timer.timeout.connect(_on_at_home_timeout)
	add_child(at_home_timer)
	
	# Timer para atualizar posição do Pacman a cada 0.1s
	chase_update_timer = Timer.new()
	chase_update_timer.wait_time = 0.1
	chase_update_timer.timeout.connect(_on_chase_update)
	add_child(chase_update_timer)
	
	# Timer para gerar novos pontos de fuga
	run_away_update_timer = Timer.new()
	run_away_update_timer.wait_time = 2.0
	run_away_update_timer.timeout.connect(_on_run_away_update)
	add_child(run_away_update_timer)
	
	# Conectar sinais
	GhostStateManager.state_changed_to_scatter.connect(_on_global_scatter)
	GhostStateManager.state_changed_to_chase.connect(_on_global_chase)
	GhostStateManager.power_pellet_eaten.connect(_on_power_pellet_eaten)
	nav_agent.target_reached.connect(_on_target_reached)
	
		# Conectar colisão do DetectionArea
	if has_node("DetectionArea"):
		$DetectionArea.body_entered.connect(_on_body_entered)
	
	# Iniciar na base (com delay)
	call_deferred("start_at_home")

func _physics_process(delta):
	var distance = global_position.distance_to(nav_agent.target_position)
	if distance < 5.0 and (current_state == GhostState.STARTING_AT_HOME or current_state == GhostState.SCATTER):
		_on_target_reached()
		
	if nav_agent.is_navigation_finished():
		return
		
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = direction * speed
	move_and_slide()

# Estados individuais
func start_at_home():
	set_visual_state(false)
	current_state = GhostState.STARTING_AT_HOME
	# Desabilitar colisão com paredes
	collision_layer = 0
	collision_mask = 0
	if movement_targets and movement_targets.at_home_targets.size() > 0:
		nav_agent.target_position = movement_targets.at_home_targets[current_home_index]
		at_home_timer.start()

func scatter():
	set_visual_state(false)
	collision_layer = 2  # Ghosts
	collision_mask = 1   # Walls
	chase_update_timer.stop()
	run_away_update_timer.stop()
	if current_state == GhostState.EATEN:
		return
	current_state = GhostState.SCATTER
	if movement_targets and movement_targets.scatter_targets.size() > 0:
		nav_agent.target_position = movement_targets.scatter_targets[current_scatter_index]

func chase():
	set_visual_state(false)
	run_away_update_timer.stop()
	
	current_state = GhostState.CHASE
	
	# INICIAR o timer de atualização
	chase_update_timer.start()
	
	if target:
		nav_agent.target_position = calculate_chase_target()

func run_away():
	current_state = GhostState.RUN_AWAY
	chase_update_timer.stop()
	
	set_visual_state(true)  # Modo assustado
	
	var random_pos = get_random_escape_position()
	nav_agent.target_position = random_pos
	
	# Iniciar timer para gerar novos pontos
	run_away_update_timer.start()
	
	print("😱 Fugindo para: ", random_pos)

func get_eaten():
	current_state = GhostState.EATEN
	run_away_update_timer.stop()
	chase_update_timer.stop()
	
	# Desabilitar colisão com paredes
	collision_layer = 0
	collision_mask = 0
	
	# Visual somente Olhos
	set_visual_state_eaten(true)
	
	# Velocidade dobrada
	speed = 160
	
	# Ir para casa
	if movement_targets and movement_targets.at_home_targets.size() > 0:
		nav_agent.target_position = movement_targets.at_home_targets[0]
	
	print("💀 Fantasma comido! Voltando para casa...")

# Método para override nos filhos
func calculate_chase_target() -> Vector2:
	return target.global_position if target else global_position

# Callbacks
func _on_at_home_timeout():
	GhostStateManager.start_scatter_mode()
	print("🏠 Saiu da base, entrando em SCATTER")

func _on_target_reached():
	match current_state:
		GhostState.STARTING_AT_HOME:
			current_home_index = 1 if current_home_index == 0 else 0
			nav_agent.target_position = movement_targets.at_home_targets[current_home_index]
		GhostState.SCATTER:
			current_scatter_index = (current_scatter_index + 1) % movement_targets.scatter_targets.size()
			nav_agent.target_position = movement_targets.scatter_targets[current_scatter_index]
		GhostState.EATEN:
			# Chegou em casa, voltar para chase
			speed = 80.0  # Velocidade normal
			
			collision_layer = 2  # Ghosts
			collision_mask = 1   # Walls
			
			global_position = movement_targets.at_home_targets[1]
			
			set_visual_state_eaten(false)
			chase()
			print("🏠 Chegou em casa, voltando para perseguição")

func _on_chase_update():
	if current_state == GhostState.CHASE and target:
		nav_agent.target_position = calculate_chase_target()

func _on_run_away_update():
	if current_state == GhostState.RUN_AWAY:
		var new_random_pos = get_random_escape_position()
		nav_agent.target_position = new_random_pos
		print("🔄 Novo ponto de fuga: ", new_random_pos)
	
func get_random_escape_position() -> Vector2:
	# Posição aleatória no mapa
	return Vector2(randf_range(-300, 300), randf_range(-300, 300))
	
func set_visual_state(is_scared: bool):
	if is_scared:
		normal_sprite.visible = false
		scare_sprite.visible = true
		anim_player.play("Scare")
	else:
		normal_sprite.visible = true
		scare_sprite.visible = false
		anim_player.play("Move-h")

func set_visual_state_eaten(is_eaten: bool):
	if is_eaten:
		normal_sprite.visible = false
		scare_sprite.visible = false
		eaten_sprite.visible = true
	else:
		normal_sprite.visible = true
		scare_sprite.visible = false
		eaten_sprite.visible = false

func _on_body_entered(body):
	if body.name == "PacMan":
		if current_state == GhostState.RUN_AWAY:
			# Pacman comeu o fantasma
			get_eaten()
			print("💀 Pacman comeu fantasma!")
		elif current_state == GhostState.CHASE or current_state == GhostState.SCATTER:
			# Fantasma comeu o Pacman
			print("👻 Fantasma comeu Pacman!")
			body.die()  # Implementar depois

# Sinais do StateManager
func _on_global_scatter():
	if current_state != GhostState.EATEN:
		scatter()

func _on_global_chase():
	if current_state != GhostState.EATEN:
		chase()

func _on_power_pellet_eaten():
	if current_state != GhostState.EATEN:
		run_away()
