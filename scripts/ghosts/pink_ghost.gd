extends GhostBase

func _ready():
	movement_targets = load("res://resources/movement_targets/pink_movement_targets.tres")
	target = get_tree().get_first_node_in_group("pacman")
	super._ready()

func calculate_chase_target() -> Vector2:
	return target.global_position if target else global_position
