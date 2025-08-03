extends Area2D

@onready var laser_prefab = preload("res://Goblin's_Path/prefabs/laser(previous).tscn")
@onready var explosion_prefab = preload("res://Goblin's_Path/prefabs/explosion(previous).tscn")
signal ship_killed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("player_up") and position.y > 50:
		position.y -= 5
	if Input.is_action_pressed("player_down") and position.y < 600:
		position.y += 5
	if Input.is_action_pressed("player_right") and position.x < 1100:
		position.x += 5
	if Input.is_action_pressed("player_left") and position.x > 50:
		position.x -= 5
		
	if Input.is_action_just_pressed("player_shoot"):
		# make a laser
		var laser = laser_prefab.instantiate()
		laser.position = position
		get_parent().add_child(laser)


func _on_area_entered(area):
	if area is enemy_laser:
		var explosion = explosion_prefab.instantiate()
		explosion.position = position
		get_parent().add_child(explosion)
		queue_free()
		ship_killed.emit()
