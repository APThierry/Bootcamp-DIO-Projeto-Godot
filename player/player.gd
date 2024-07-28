class_name Player

extends CharacterBody2D

#Quando o node estiver pronto
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var vida_bar: ProgressBar = $VidaBar

@export_category("Movimentos")
@export var speed: float = 3

@export_category("Espada")
@export var sword_damage: int = 2

@export_category("Ritual")
@export var ritual_dano: int = 2
@export var ritual_intervalo: float = 30
@export var ritual_cena: PackedScene

@export_category("Vida")
@export var vida: int = 100
@export var vida_max: int = 100

@export_category("Animação Morte")
@export var death_prefab: PackedScene

var input_vector: Vector2
var is_correndo: bool = false
var was_correndo: bool = false
var is_atacando: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

signal meat_collected(value: int)

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value: int): GameManager.meat_counter += 1)

func _process(delta) -> void:
	GameManager.player_position = position
	
	#Ler input
	read_input()

	#Processar ataque
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		ataque()

	#Processar animação e rotação de sprite
	play_animacoes()
	if not is_atacando:
		rotate_sprite()
	
	#Processar dano
	upadate_hitbox(delta)
	
	#Processar ritual
	update_ritual(delta)
	
	#Atulaizar Barra de Vida
	vida_bar.max_value = vida_max
	vida_bar.value = vida

func _physics_process(delta: float) -> void:
	# Modificar a velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_atacando:
		target_velocity *= 0.15
	velocity = lerp(velocity, target_velocity, 0.15)
	move_and_slide()

func update_attack_cooldown(delta: float) -> void:
	#Atualizando o temporizador do ataque
	if attack_cooldown > 0:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_correndo = false
			is_atacando = false
			animation_player.play("Parado")

func read_input() -> void:
		# Obter o input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Apagar deadzone do Input vector
	var deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0

	# Atualizar o is_correndo
	was_correndo = is_correndo
	is_correndo = not input_vector.is_zero_approx()

func play_animacoes() -> void:
	#Tocar animação
	if not is_atacando:
		if was_correndo != is_correndo:
			if is_correndo:
				animation_player.play("Correndo")
			else: 
				animation_player.play("Parado")

func rotate_sprite() -> void:
	# Girar Sprite
	if input_vector.x > 0:
		#Desmarcar flip_h do Sprite2D
		sprite.flip_h = false
		pass
	elif  input_vector.x < 0:
		#Marcar flip_h do sprite2D
		sprite.flip_h = true
		pass

func ataque() -> void:
	if is_atacando:
		return
	
	#Tocar animação
	animation_player.play("attack_lateral_1")
	#ataque lateral 1
	#ataque lateral 2
	
	#Configurar temporizador
	attack_cooldown = 0.6
	
	#Marcar ataque
	is_atacando = true

func damage_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_enemy = (enemy.position - position).normalized()
			var attack_direcao: Vector2
			if sprite.flip_h:
				attack_direcao = Vector2.LEFT
			else:
				attack_direcao = Vector2.RIGHT
			var dot_product = direction_enemy.dot(attack_direcao)
			if dot_product >= 0.3:
				enemy.damage(sword_damage)

func upadate_hitbox(delta: float) -> void:
	#Temporazidor
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	#Frenquancia
	hitbox_cooldown = 0.5
	
	#Detectar inimigo
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)

func damage(amount: int) -> void:
	if vida <= 0: return
	
	vida-= amount;
	print("Dano: " , vida)
	
	#Piscar node (dano)
	#modulate = Color.RED
	#var tween = create_tween()
	#tween.set_ease(Tween.EASE_IN)
	#tween.set_trans(Tween.TRANS_QUINT)
	#tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Processar Morte
	if vida <= 0:
		morte()
	
func morte() -> void:
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		get_parent().add_child(death_object)
		death_object.position = position
	queue_free()

func heal(amount: int) -> int:
	vida += amount
	if vida > vida_max:
		vida = vida_max
		print("Player recebeu cura de ", amount, ". A vida total é de ", vida, "/", vida_max)
	return vida

func update_ritual(delta: float) -> void:
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_intervalo
	
	#Criar o ritual
	var ritual = ritual_cena.instantiate()
	ritual.damage = ritual_dano
	add_child(ritual)
	pass
