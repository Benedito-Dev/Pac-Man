extends CharacterBody2D

@export var velocidade_pacman = 100
@onready var sprite = $Pacman
@onready var anim_player = $AnimationPlayer
@onready var BlinkBackground = $"../IntervalBackground"
@onready var TimerBackground = $"../TimerBackground"
@onready var BackgroundWhite = $"../FundoBranco"
@onready var red_ghost = get_node("../RedGhost")
@export var points = 0

var direcao = Vector2.RIGHT 
var is_power_mode: bool = false  # Controle do estado de power

func _ready():
	# Garante que a animação toca em loop desde o início
	anim_player.play("horizontal")

func _physics_process(delta):
	# Captura nova direção imediatamente
	if Input.is_action_just_pressed("ui_right"):
		direcao = Vector2.RIGHT
	elif Input.is_action_just_pressed("ui_left"):
		direcao = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_down"):
		direcao = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_up"):
		direcao = Vector2.UP
	
	# Aplica rotação
	aplicar_rotacao(direcao)
	
	# Move continuamente na direção atual
	velocity = direcao * velocidade_pacman
	move_and_slide()

func aplicar_rotacao(direcao: Vector2):
	if direcao.x > 0:  # Direita
		sprite.rotation = 0
		sprite.flip_h = false
	elif direcao.x < 0:  # Esquerda
		sprite.rotation = 0
		sprite.flip_h = true
	elif direcao.y > 0:  # Baixo
		sprite.rotation = deg_to_rad(90)
		sprite.flip_h = false
	elif direcao.y < 0:  # Cima
		sprite.rotation = deg_to_rad(-90)
		sprite.flip_h = false

func _on_area_deteccao_area_entered(area):
	# Verifica se o nome contém "Pellet"
	if "Pellet" in area.name:
		points += 1
		area.queue_free()
	
	if "Power" in area.name:
		Power()
		points += 10
		area.queue_free()

func Power():
	# Se já está em power mode, reinicia o timer
	if is_power_mode:
		TimerBackground.start()  # Reinicia o timer
		return
	
	# Inicia o power mode
	is_power_mode = true
	
	# Conecta o timer principal
	TimerBackground.timeout.connect(_on_power_mode_ended)
	TimerBackground.start()
	
	# Configura e inicia a piscada
	BlinkBackground.timeout.connect(_on_blink_timeout)
	BackgroundWhite.visible = true
	BlinkBackground.start()

func _on_blink_timeout():
	# Alterna a visibilidade apenas se ainda estiver em power mode
	if is_power_mode:
		BackgroundWhite.visible = !BackgroundWhite.visible

func _on_power_mode_ended():
	# Finaliza o power mode
	is_power_mode = false
	
	# Para o timer de piscada
	BlinkBackground.stop()
	
	# Garante que o fundo branco fica invisível
	BackgroundWhite.visible = false
	
