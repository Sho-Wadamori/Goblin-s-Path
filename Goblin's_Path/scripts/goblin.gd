extends CharacterBody2D # <-- EDIT: Change from Area2D to CharacterBody2D

@onready var laser_prefab = preload("res://Goblin's_Path/prefabs/laser.tscn")
@onready var explosion_prefab = preload("res://Goblin's_Path/prefabs/explosion.tscn")
signal ship_killed

# ------------------------- Adjustable Variables -------------------------
const SPEED = 120.0 # how fast the character moves

# ------------------------- every tick -------------------------
func _physics_process(delta): # <-- EDIT: Change from _process to _physics_process
	# ADDED: Initialize input direction vector
	var input_direction = Vector2.ZERO

	# ------------------------- movement -------------------------
	if Input.is_action_pressed("player_up"):
		input_direction.y -= 1
	if Input.is_action_pressed("player_down"):
		input_direction.y += 1
	if Input.is_action_pressed("player_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("player_right"):
		input_direction.x += 1

	# prevent faster diagonal movement
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()

	# velocity calculation
	velocity = input_direction * SPEED

	# CharacterBody2D collision
	move_and_slide()

	# ------------------------- shooting mechanics -------------------------
	if Input.is_action_just_pressed("player_shoot"):
		# make a laser
		var laser = laser_prefab.instantiate()
		laser.position = position # Laser position still uses the character's current position
		get_parent().add_child(laser)


# ------------------------- death -------------------------
func _on_area_entered(area):
	# This signal still works correctly if your enemy_laser is an Area2D
	# and your CharacterBody2D has a CollisionShape2D attached (which it needs)
	if area is enemy_laser:
		var explosion = explosion_prefab.instantiate()
		explosion.position = position
		get_parent().add_child(explosion)
		queue_free()
		ship_killed.emit()
