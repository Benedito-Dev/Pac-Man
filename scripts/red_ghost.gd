extends CharacterBody2D

# Estados do fantasma
enum GhostState {
	SCATTER, CHASE, RUN_AWAY, EATEN, STARTING
}

# Configurações
@export var player: CharacterBody2D
@export var speed = 80

# Componentes
@onready var anim_ghost_red = $AnimationPlayer
@onready var scatter_timer = $ScatterTimer
@onready var detection_area = $DetectionArea
@onready var nav_agent = $NavigationAgent2D

# Estado atual
var current_state = GhostState.STARTING
var scatter_points = []
var current_scatter_index = 0

func _ready():
	anim_ghost_red.play("Move-h")
	
	# Pontos de patrulha
	scatter_points = [
		Vector2(150, 258),   # Centro-direita
		Vector2(50, 258),   # Mais à direita
		Vector2(50, 158),   # Direita-baixo
		Vector2(150, 158)    # Centro-baixo
	]
	
	# Configura NavigationAgent2D
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 8.0
	nav_agent.max_speed = speed
	
	# Timers
	scatter_timer.wait_time = 8.0
	scatter_timer.timeout.connect(_on_scatter_timeout)
	detection_area.body_entered.connect(_on_body_entered)
	
	# Aguarda mapa estar pronto
	call_deferred("setup_navigation")

func setup_navigation():
	# Conecta ao mapa de navegação
	var navigation_map = get_world_2d().get_navigation_map()
	nav_agent.set_navigation_map(navigation_map)
	
	start_scatter()
	print("👻 Fantasma com IA iniciado!")

func _physics_process(delta):
	# IA decide o comportamento
	match current_state:
		GhostState.SCATTER:
			ai_scatter_behavior()
		GhostState.CHASE:
			ai_chase_behavior()
		GhostState.RUN_AWAY:
			ai_run_away_behavior()
		GhostState.EATEN:
			ai_eaten_behavior()
		GhostState.STARTING:
			start_scatter()
	
	# Move usando IA de navegação
	ai_movement()

func ai_movement():
	# A IA do Godot calcula o melhor caminho
	if nav_agent.is_navigation_finished():
		return
	
	var next_path_position = nav_agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()

# IA: PATRULHA
func start_scatter():
	current_state = GhostState.SCATTER
	scatter_timer.start()
	print("🚶 IA: Iniciando patrulha inteligente")

func ai_scatter_behavior():
	var target = scatter_points[current_scatter_index]
	
	# IA calcula melhor caminho para o target
	nav_agent.target_position = target
	
	# Chegou perto do ponto?
	if global_position.distance_to(target) < 30:
		current_scatter_index = (current_scatter_index + 1) % scatter_points.size()
		print("🎯 IA: Próximo ponto de patrulha")

# IA: PERSEGUIÇÃO
func start_chase():
	current_state = GhostState.CHASE
	print("🎯 IA: Perseguição inteligente ativada")

func ai_chase_behavior():
	if player:
		# IA calcula melhor caminho para o Pacman
		nav_agent.target_position = player.global_position

# IA: FUGA
func start_run_away():
	current_state = GhostState.RUN_AWAY
	print("😱 IA: Fuga inteligente ativada")

func ai_run_away_behavior():
	if player:
		# IA calcula ponto de fuga inteligente
		var flee_direction = (global_position - player.global_position).normalized()
		var flee_distance = 150
		var flee_target = global_position + flee_direction * flee_distance
		
		# IA encontra caminho seguro para fugir
		nav_agent.target_position = flee_target

# IA: MORTO
func start_eaten():
	current_state = GhostState.EATEN
	print("💀 IA: Voltando para casa")

func ai_eaten_behavior():
	var home = Vector2(400, 300)
	
	# IA calcula melhor caminho para casa
	nav_agent.target_position = home
	
	# Chegou em casa?
	if global_position.distance_to(home) < 25:
		start_chase()

# Eventos
func _on_scatter_timeout():
	start_chase()

func trigger_run_away():
	start_run_away()

func trigger_eaten():
	start_eaten()

func _on_body_entered(body):
	if body == player:
		match current_state:
			GhostState.RUN_AWAY:
				print("🍽️ IA: Fui capturado!")
				trigger_eaten()
			GhostState.CHASE, GhostState.SCATTER:
				print("💀 IA: Capturei o Pacman!")
