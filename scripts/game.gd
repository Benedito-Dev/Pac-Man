extends Node2D

@onready var Soundgame = $SoundGame
@onready var label_points = $Points
@onready var Pacman = $PacMan
@onready var PortalTimer = $PortalTimer
@onready var tile_map = $Map
@onready var BlinkBackground = $IntervalBackground
@onready var BackgroundWhite = $FundoBranco

var is_power_mode: bool = false

func _ready():
	Soundgame.play()
	
	# Conectar sinal do GhostStateManager
	GhostStateManager.power_pellet_eaten.connect(_on_power_mode_started)
	GhostStateManager.power_mode_ended.connect(_on_power_mode_ended)
	
	BlinkBackground.timeout.connect(_on_blink_timeout)  # Conectar aqui
	
func _process(delta):
	# Verificar se Pacman esta fora do mapa
	if Pacman.global_position.x > 800:
		Pacman.global_position.x = -1
	elif Pacman.global_position.x < -1:
		Pacman.global_position.x = 801
	
	label_points.text = str(Pacman.points)

func _on_power_mode_started():
	# Inicia efeitos visuais do power mode
	is_power_mode = true
	
	# Inicia a piscada
	BackgroundWhite.visible = true
	BlinkBackground.start()
	print("✨ Efeitos visuais do power mode iniciados")

func _on_blink_timeout():
	if is_power_mode:
		BackgroundWhite.visible = !BackgroundWhite.visible

func _on_power_mode_ended():
	# Para efeitos visuais
	is_power_mode = false
	BlinkBackground.stop()
	BackgroundWhite.visible = false

func _on_sound_game_finished():
	Soundgame.play()

func _on_portal_timer_timeout():
	tile_map.set_cell(Vector2i(19, 16), 0, Vector2i(40, 0))
