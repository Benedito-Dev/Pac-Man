extends Node2D

@onready var StartSound = $AudioStart
@onready var TransitionSound = $AudioTransition
@onready var StartLabel = $background/Start
@onready var blink_timer = $BlinkTimer
@onready var transition_rect = $CanvasLayer/TransitionRect

var esta_visivel = true
var piscando = false  # Controla se está piscando

func _ready():
	# Configura o timer MAS NÃO INICIA AINDA
	blink_timer.wait_time = 0.15  # Mais rápido para piscar durante o som
	# Não chama blink_timer.start() aqui

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		print("Start pressionado")
		tocar_som_start()
		iniciar_piscada()  # Começa a piscar quando toca o som

func tocar_som_start():
	if StartSound:
		StartSound.play()
		# Conecta o sinal para saber quando o som termina
		StartSound.finished.connect(_on_sound_finished)
	else:
		print("Som não carregado")

func iniciar_piscada():
	piscando = true
	blink_timer.start()  # Inicia o timer para piscar
	esta_visivel = true
	StartLabel.visible = true

func parar_piscada():
	piscando = false
	blink_timer.stop()  # Para o timer
	StartLabel.visible = true  # Garante que fica visível

# Quando o som termina
func _on_sound_finished():
	parar_piscada()
	TransitionSound.play()
	iniciar_transicao()

# Quando o timer acaba (pisca)
func _on_blink_timer_timeout():
	if piscando:  # Só pisca se estiver no modo de piscada
		esta_visivel = !esta_visivel
		StartLabel.visible = esta_visivel

# NOVA FUNÇÃO - Animação da cortina preta
func iniciar_transicao():
	# Faz a cortina aparecer descendo de cima para baixo
	var tween = create_tween()
	
	# Começa invisível no topo
	transition_rect.modulate.a = 1  # Torna totalmente opaco
	transition_rect.scale.y = 0     # Começa "enrolada" no topo
	
	# Anima descendo (crescendo verticalmente)
	tween.tween_property(transition_rect, "scale:y", 1.0, 1.0)
	
	# Quando terminar a animação, troca de cena
	tween.tween_callback(mudar_cena)

# NOVA FUNÇÃO - Troca para a cena do jogo
func mudar_cena():
	# Troque pelo caminho da sua cena do jogo
	var cena_principal = load("res://scenes/game.tscn")
	get_tree().change_scene_to_packed(cena_principal)
