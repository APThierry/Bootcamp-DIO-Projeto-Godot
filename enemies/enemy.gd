class_name Enemy

extends Node2D

@export_category("Life")
@export var vida: int = 10
@export var death_prefab: PackedScene
var damage_digit_prefab: PackedScene

@onready var damage_digit_marker = $DanoMarcador

@export_category("Drops")
@export var drop_chance: float = 0.1
@export var drop_items: Array[PackedScene]
@export var drop_raridade: Array[float]

func _ready():
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")

func damage(amount: int) -> void:
	vida-= amount;
	print("Dano: " , vida)
	
	#Piscar node (dano)
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	#Criar Digito do Dano
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)
	
	# Processar Morte
	if vida <= 0:
		morte()
	
func morte() -> void:
	#Caveira
	if death_prefab:
		var death_object = death_prefab.instantiate()
		get_parent().add_child(death_object)
		death_object.position = position
	
	#Drop
	if randf() <= drop_chance:
		drop_item()
	
	#Incrementar contador
	GameManager.mosnter_defeated_counter += 1
	
	#Deletar Node
	queue_free()

func drop_item() -> void:
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	get_parent().add_child(drop)

func get_random_drop_item() -> PackedScene:
	#Lista com 1 item
	if drop_items.size() == 1:
		return drop_items[0]

	#Calcular chance maxima
	var max_chance: float = 0.0
	for drop_chance in drop_raridade:
		max_chance += drop_chance
	
	#Jogar dado
	var random_value = randf() * max_chance
	
	#Girar a roleta
	var agulha: float = 0.0
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance = drop_raridade[1] if i < drop_raridade.size() else 1
		if random_value <= drop_chance + agulha:
			return drop_item
		agulha += drop_chance
	
	return drop_items[0]

