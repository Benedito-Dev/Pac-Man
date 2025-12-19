extends GhostBase

var red_ghost: GhostBase

func _ready():
	movement_targets = load("res://resources/movement_targets/blue_movement_targets.tres")
	target = get_tree().get_first_node_in_group("pacman")
	red_ghost = get_tree().get_first_node_in_group("red_ghost")
	super._ready()

#func _draw():
#	if not target or not red_ghost:
#		return
#	
#	# Posições locais (relativas ao fantasma azul)
#	var pacman_local = to_local(target.global_position)
#	var red_ghost_local = to_local(red_ghost.global_position)
#	var target_local = to_local(calculate_chase_target())
#	
#	# Linha do fantasma azul → fantasma vermelho → pac-man → alvo
#	draw_line(Vector2.ZERO, red_ghost_local, Color.RED, 2.0)
#	draw_line(red_ghost_local, pacman_local, Color.YELLOW, 2.0)
#	draw_line(pacman_local, target_local, Color.BLUE, 2.0)
#	
#	# Círculo no alvo final
#	draw_circle(target_local, 8, Color.CYAN)

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

#func _process(delta):
#	queue_redraw()  # Redesenha a cada frame
