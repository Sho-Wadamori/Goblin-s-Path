extends Node2D

#in charge of keeping score and spawning enemies
@onready var SceneChangeAnimation = $SceneChangeAnimation/AnimationPlayer

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_ui()
	SceneChangeAnimation.get_parent().get_node("ColorRect").color.a = 255
	SceneChangeAnimation.play("fade_out")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
	
# ------ SPAWNING ENEMY SHIPS ------
#func _on_enemy_timer_timeout():
	#var enemy = enemy_prefab.instantiate()
	##position
	#var random_y = randi_range(30, 610)
	#enemy.position = Vector2(1200, random_y)
	#enemy.enemy_killed.connect(_on_enemy_killed)
	##add to the tree
	#add_child(enemy)

func _update_ui():
	$game_UI/score_label.text = "SCORE: " + str(score)

func _on_enemy_killed():
	score += 50
	_update_ui()


func _on_restart_timer_timeout():
	get_tree().reload_current_scene()


#func _on_goblin_goblin_killed() -> void:
	#get_tree().change_scene_to_file("res://Goblin's_Path/scenes/GameOver.tscn")
	#print("DEBUG: Player Killed")
