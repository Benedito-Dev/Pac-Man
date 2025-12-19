extends GhostBase

func _ready():
	movement_targets = load("res://resources/movement_targets/pink_movement_targets.tres")
	target = get_tree().get_first_node_in_group("pacman")
	super._ready()

# Override da lógica de perseguição (fantasma rosa = interceptação)
func calculate_chase_target() -> Vector2:
	if not target:
		return global_position
	
	# Pegar direção atual do Pacman
	var pacman_direction = target.direcao  # Variável pública do pacman.gd
	
	# Calcular posição 2 casas (40px) à frente
	var intercept_position = target.global_position + (pacman_direction * 40)
	
	return intercept_position
