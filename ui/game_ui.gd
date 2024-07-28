extends CanvasLayer

@onready var timer_label: Label = %Timer
#@onready var gold_label: Label = %Gold
@onready var meat_label: Label = %Meat


func _process(delta: float):
	#Upadate Labls
	timer_label.text = GameManager.time_elapsed_string
	meat_label.text = str(GameManager.meat_counter)
	
