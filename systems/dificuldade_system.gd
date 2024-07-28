extends Node

@export var mob_spawner: MobSpawner
@export var initial_spawn_rate: float = 60.0
@export var spawn_rate_por_minutes: float = 30.0
@export var wave_duration: float = 20.0
@export var break_intensity: float = 0.5

var time: float = 0.0

func _process(delta: float) -> void:
	# Ignorar GameOver
	if GameManager.is_game_over: return
	
	#Incrementar temporizador
	time += delta
	
	#Dificuldade Linear (Linha Verde)
	var spawn_rate = initial_spawn_rate + spawn_rate_por_minutes * (time / 60.0)
	
	#Sistema de Ondas (Linha Rosa)
	var sin_wave = sin((time * TAU) / wave_duration)
	var waver_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1)
	spawn_rate *= waver_factor
	
	#Aplicar Dificulade
	mob_spawner.mobs_minutes = spawn_rate
