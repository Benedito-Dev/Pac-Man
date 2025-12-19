extends CharacterBody2D

@export var velocidade_pacman = 100
@onready var sprite = $Pacman
@onready var anim_player = $AnimationPlayer
@export var points = 0
@export var lives = 3

var direcao = Vector2.RIGHT 

signal life_lost

func _ready():
	anim_player.play("horizontal")
	
	# Conectar área de detecção do próprio Pac-Man
	if has_node("AreaDeteccao"):
		$AreaDeteccao.area_entered.connect(_on_area_deteccao_area_entered)

func _physics_process(delta):
	# Captura nova direção
	if Input.is_action_just_pressed("ui_right"):
		direcao = Vector2.RIGHT
	elif Input.is_action_just_pressed("ui_left"):
		direcao = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_down"):
		direcao = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_up"):
		direcao = Vector2.UP
	
	# Aplica rotação e movimento
	aplicar_rotacao(direcao)
	velocity = direcao * velocidade_pacman
	move_and_slide()
	
func die():
	lives -= 1
	life_lost.emit()
	print("💀 Pacman morreu! Vidas restantes: ", lives)
	if lives <= 0:
		game_over()
	else:
		respawn()

func game_over():
	print("🎮 GAME OVER!")
	# Parar jogo, mostrar tela de game over
	get_tree().paused = true

func respawn():
	# Voltar para posição inicial
	global_position = Vector2(30, 338)  # Ajustar posição
	direcao = Vector2.RIGHT
	print("🔄 Pacman respawnou!")


func aplicar_rotacao(direcao: Vector2):
	if direcao.x > 0:
		sprite.rotation = 0
		sprite.flip_h = false
	elif direcao.x < 0:
		sprite.rotation = 0
		sprite.flip_h = true
	elif direcao.y > 0:
		sprite.rotation = deg_to_rad(90)
		sprite.flip_h = false
	elif direcao.y < 0:
		sprite.rotation = deg_to_rad(-90)
		sprite.flip_h = false

func _on_area_deteccao_area_entered(area):
	if "Pellet" in area.name:
		points += 1
		get_parent().pellet_collected()
		area.queue_free()
	elif "Power" in area.name:
		points += 10 
		get_parent().pellet_collected()
		GhostStateManager.trigger_run_away()
		area.queue_free()
		print("💊 Power pellet comido!")
