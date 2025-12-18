extends Node2D

@onready var Soundgame = $SoundGame
@onready var label_points = $Points
@onready var Pacman = $PacMan
@onready var PortalTimer = $PortalTimer
@onready var tile_map = $Map

func _ready():
	Soundgame.play()
	
func _process(delta):
	# Verificar se Pacman esta fora do mapa
	if Pacman.global_position.x > 800:
		Pacman.global_position.x = -1
	elif Pacman.global_position.x < -1:
		Pacman.global_position.x = 801
	else:
		pass
	
	label_points.text = str(Pacman.points)

func _on_sound_game_finished():
	Soundgame.play()

func _on_portal_timer_timeout():
	# Trocar portão (28, 0) por caminho (40, 0)
	tile_map.set_cell(Vector2i(19, 16), 0, Vector2i(40, 0))
	print("🚪 Portão aberto! Trocado de (28,0) para (40,0)")
