extends Node2D

@onready var Soundgame = $SoundGame
@onready var points_container = $PointsContainer
@onready var label_points = $Points
var current_level: int = 1
var total_pellets: int = 322
var collected_pellets: int = 0
var number_textures = []
var last_points = -1 
@onready var Pacman = $PacMan
@onready var life1_sprite = $Lifes/Life1
@onready var life2_sprite = $Lifes/Life2
@onready var life3_sprite = $Lifes/Life3
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
	
	BlinkBackground.timeout.connect(_on_blink_timeout)
	
	# Conectar sinal de morte do Pacman
	Pacman.life_lost.connect(update_lives_display)
	
	# Carregar sprites dos números (0-9)
	for i in range(10):
		var texture = load("res://sprites/numbers/" + str(i) + ".png")
		number_textures.append(texture)
		
	points_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
func _process(delta):
	# Verificar se Pacman esta fora do mapa
	if Pacman.global_position.x > 800:
		Pacman.global_position.x = -1
	elif Pacman.global_position.x < -1:
		Pacman.global_position.x = 801
	
	if Pacman.points != last_points:
		update_points_display(Pacman.points)
		last_points = Pacman.points
		
	label_points.text = str(Pacman.points)
	
func update_lives_display():
	# Mostrar/esconder sprites baseado nas vidas do Pacman
	life1_sprite.visible = Pacman.lives >= 1
	life2_sprite.visible = Pacman.lives >= 2
	life3_sprite.visible = Pacman.lives >= 3

func update_points_display(points: int):
	# Limpar números antigos
	for child in points_container.get_children():
		points_container.remove_child(child)
		child.queue_free()
	
	# Converter pontos para texto (ex: 1250 → "1250")
	var points_str = str(points)
	
	# Criar sprite para cada dígito
	for digit_char in points_str:
		var digit = int(digit_char)  # "1" → 1
		var sprite = Sprite2D.new()
		sprite.texture = number_textures[digit]  # Usar textura do número
		sprite.scale = Vector2(0.5, 0.5)  # ← 50% do tamanho originals
		points_container.add_child(sprite)

func pellet_collected():
	collected_pellets += 1
	if collected_pellets >= total_pellets:
		next_level()
		
func next_level():
	current_level += 1
	collected_pellets = 0  # Reset contador
	print("🎉 Level ", current_level, " alcançado!")
	
	# Reset do jogo (implementar depois)
	reset_game()

func reset_game():
	# Placeholder - implementar reset completo
	print("🔄 Resetando jogo para próximo level...")
	
	# 1. Reset Pacman
	Pacman.global_position = Vector2(30, 338)  # Posição inicial
	Pacman.direcao = Vector2.RIGHT
	
	# 2. Reset Fantasmas - voltar para base
	var all_nodes = get_tree().get_nodes_in_group("ghosts")
	for node in all_nodes:
		if node is GhostBase:
			if node.movement_targets and node.movement_targets.at_home_targets.size() > 0:
				node.global_position = node.movement_targets.at_home_targets[0]
		
			# Reiniciar estado
			node.start_at_home()
	
	tile_map.set_cell(Vector2i(19, 16), 0, Vector2i(28, 0))
			
	# 3. Reiniciar timer do portão
	PortalTimer.start()

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
