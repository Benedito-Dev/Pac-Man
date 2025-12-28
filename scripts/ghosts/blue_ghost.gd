extends GhostBase

var red_ghost: GhostBase
var can_leave_home: bool = false

func _ready():
	movement_targets = load("res://resources/movement_targets/blue_movement_targets.tres")
	
	target = get_tree().get_first_node_in_group("pacman")
	red_ghost = get_tree().get_first_node_in_group("red_ghost")
	
	target.connect("points_changed", _on_pacman_points_changed)
	super._ready()
	
	at_home_timer.stop()
	
func _on_global_scatter():
	if not can_leave_home:
		return  # Ignorar sinal se não pode sair
	
	# Só executar se pode sair da base
	if current_state != GhostState.EATEN:
		scatter()

func _on_global_chase():
	if not can_leave_home:
		return  # Ignorar sinal se não pode sair
	
	# Só executar se pode sair da base
	if current_state != GhostState.EATEN:
		chase()

func _on_pacman_points_changed(points: int):
	print(points)
	if points >= 30 and not can_leave_home:  # 30 pontos = 30 pellets
		can_leave_home = true
		at_home_timer.start()
		print("🔵 Azul pode sair da base!")

func _on_at_home_timeout():
	if not can_leave_home:
		return
	
	# Chamar método da classe pai
	super._on_at_home_timeout()

func calculate_chase_target() -> Vector2:
	if not target or not red_ghost:
		return global_position
	
	# 1. Posição 2 tiles à frente do Pac-Man (20 pixels = 1 tile)
	var pacman_future_pos = target.global_position + (target.direcao * 20)
	
	# 2. Vetor do fantasma vermelho até essa posição
	var vector_red_to_future = pacman_future_pos - red_ghost.global_position
	
	# 3. Duplicar a distância (alvo final)
	var inky_target = pacman_future_pos + vector_red_to_future
	
	return inky_target
