extends Node

@export var speed = 1.0

var enemy: Enemy
var sprite: AnimatedSprite2D

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")

func _physics_process(delta: float) -> void:
	# Ignorar GameOver
	if GameManager.is_game_over: return
	
	#Calcular direção
	var player_position = GameManager.player_position
	var diference = player_position - enemy.position
	var input_vector = diference.normalized()

	#Movimento
	enemy.velocity = input_vector * speed * 100.0
	enemy.move_and_slide()

	# Girar Sprite
	if input_vector.x > 0:
		#Desmarcar flip_h do Sprite2D
		sprite.flip_h = false
		pass
	elif  input_vector.x < 0:
		#Marcar flip_h do sprite2D
		sprite.flip_h = true
		pass
