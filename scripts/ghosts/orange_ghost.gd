extends GhostBase

var previous_state: GhostState
var is_scared_of_pacman: bool = false
var scare_cooldown: float = 0.0
var fear_duration_timer: Timer

func _ready():
	movement_targets = load("res://resources/movement_targets/orange_movement_targets.tres")
	target = get_tree().get_first_node_in_group("pacman")
	
	if has_node("OrangeScare"):
		$OrangeScare.body_entered.connect(_on_pacman_entered_scare_zone)
		$OrangeScare.body_exited.connect(_on_pacman_exited_scare_zone)
	
	GhostStateManager.power_mode_ended.connect(_on_power_mode_ended)
	
	fear_duration_timer = Timer.new()
	fear_duration_timer.wait_time = 3.0
	fear_duration_timer.one_shot = true
	fear_duration_timer.timeout.connect(_on_fear_duration_timeout)
	add_child(fear_duration_timer)
	
	super._ready()

func _process(delta):
	if scare_cooldown > 0:
		scare_cooldown -= delta

func calculate_chase_target() -> Vector2:
	if not target:
		return global_position
	
	if is_scared_of_pacman:
		return get_random_escape_position()
	else:
		return target.global_position

func _on_pacman_entered_scare_zone(body):
	if body.name == "PacMan" and scare_cooldown <= 0 and current_state != GhostState.RUN_AWAY and current_state != GhostState.EATEN:
		print("🟠 Laranja ficou com medo!")
		previous_state = current_state
		is_scared_of_pacman = true
		scare_cooldown = 1.0
		fear_duration_timer.start()
		
		if current_state == GhostState.CHASE or current_state == GhostState.SCATTER:
			nav_agent.target_position = calculate_chase_target()

func _on_pacman_exited_scare_zone(body):
	pass

func _on_fear_duration_timeout():
	print("🟠 Laranja não tem mais medo!")
	is_scared_of_pacman = false
	
	match GhostStateManager.current_global_state:
		GhostStateManager.GlobalGhostState.CHASE:
			chase()
		GhostStateManager.GlobalGhostState.SCATTER:
			scatter()

func _on_power_mode_ended():
	is_scared_of_pacman = false
