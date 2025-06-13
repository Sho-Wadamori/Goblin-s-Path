extends Node2D

#in charge of keeping score and spawning enemies
@onready var enemy_prefab = preload("res://Goblin's_Path/prefabs/enemy.tscn")

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	

func _on_enemy_timer_timeout():
	var enemy = enemy_prefab.instantiate()
	#position
	var random_y = randi_range(30, 610)
	enemy.position = Vector2(1200, random_y)
	enemy.enemy_killed.connect(_on_enemy_killed)
	#add to the tree
	add_child(enemy)

func _update_ui():
	$game_UI/score_label.text = "SCORE: " + str(score)

func _on_enemy_killed():
	score += 50
	_update_ui()

func _on_ship_ship_killed():
	#start the timer
	$restart_timer.start()

func _on_restart_timer_timeout():
	get_tree().reload_current_scene()
