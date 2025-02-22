class_name GameOverUI
extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var monster_label: Label = %MonsterLabel

@export var restart_delay: float = 5.0
var restar_cooldown: float

func _ready():
	time_label.text = GameManager.time_elapsed_string
	monster_label.text = str(GameManager.mosnter_defeated_counter)
	restar_cooldown = restart_delay
	
func _process(delta):
	restar_cooldown -= delta
	if restar_cooldown <= 0.0:
		restart_game()

func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()
	pass

