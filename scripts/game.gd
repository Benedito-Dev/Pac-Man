extends Node2D

@onready var Soundgame = $SoundGame
@onready var label_points = $Points
@onready var Pacman = $PacMan

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
