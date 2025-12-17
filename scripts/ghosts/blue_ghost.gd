extends CharacterBody2D

@export var speed = 80
@export var target : CharacterBody2D
@onready var navagent = $NavigationAgent2D
@onready var anim_ghost = $AnimationPlayer

func _ready():
	anim_ghost.play("Move-h")

func _physics_process(delta):
	var direction = to_local(navagent.get_next_path_position()).normalized()
	velocity = direction * speed
	
	move_and_slide()
	
func go_to_target():
	navagent.target_position = target.global_position


func _on_nav_timer_timeout():
	go_to_target() 
