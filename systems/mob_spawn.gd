class_name MobSpawner
extends Node2D

@export var criaturas: Array[PackedScene]
var mobs_minutes: int = 60.0

@onready var path_follow_2d: PathFollow2D = %PathFollow2D

var cooldown: float = 0.0


func _process(delta: float):
	# Ignorar GameOver
	if GameManager.is_game_over: return
	
	#Temporizador
	cooldown -= delta
	if cooldown > 0: return
	
	#Frequencia dos inimigos
	var intervalo = 60.0 / mobs_minutes
	cooldown = intervalo
	
	#Verificar se o ponto é valido
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b1001
	var result: Array = world_state.intersect_point(parameters, 1)
	if not result.is_empty(): return
	#Esse ponto tem colisão
	
	#Instaciar inimigo aleatoria
	var index = randi_range(0, criaturas.size() - 1)
	var criatura_secne = criaturas[index]
	var criatura = criatura_secne.instantiate()
	criatura.global_position = point
	get_parent().add_child(criatura)
	
func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
