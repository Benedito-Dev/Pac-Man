extends Resource
class_name MovementTargets

# Pontos de patrulha (4 pontos por fantasma)
@export var scatter_targets: Array[Vector2] = []

# Pontos da base (2 pontos para movimento vertical)
@export var at_home_targets: Array[Vector2] = []
