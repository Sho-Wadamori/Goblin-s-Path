# ------------------------- General Settings -------------------------
extends CharacterBody2D
class_name goblin

# ------------------------- Global Variables -------------------------
signal goblin_killed
signal player_sneaking(is_sneaking: bool)

# ------------------------- Variables -------------------------
@onready var laser_prefab = preload("res://Goblin's_Path/prefabs/laser(previous).tscn")
@onready var explosion_prefab = preload("res://Goblin's_Path/prefabs/explosion(previous).tscn")
@onready var is_sneaking: bool = false # Default is false

@export var SPEED: int = 50 # how fast the character moves

# ------------------------- Every Tick -------------------------
func _physics_process(delta):
	movement()
	mechanics()

# ------------------------- Movement -------------------------
func movement():
	var input_direction = Vector2.ZERO
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


# ------------------------- Mechanics -------------------------
func mechanics():
	# ----- Shooting Mechanics -----
	if Input.is_action_just_pressed("player_throw"):
		# make a laser
		var laser = laser_prefab.instantiate()
		laser.position = position
		get_parent().add_child(laser)

	# ----- Sneaking Mechanics -----
	var current_sneaking_state = Input.is_action_pressed("player_sneak")
	if current_sneaking_state != is_sneaking:
		is_sneaking = current_sneaking_state
		print("Am i sneaking?: ", current_sneaking_state)
		print("")

	# ----- TEMP MECHANICS -----
	if Input.is_action_pressed("player_speedbst"):  # Note: _pressed not _just_pressed
		SPEED = 200
	else:
		SPEED = 120
	


## ------------------------- Death -------------------------
#func _on_area_entered(area):
	#if area is enemy_laser:
		#var explosion = explosion_prefab.instantiate()
		#explosion.position = position
		#get_parent().add_child(explosion)
		#queue_free()
		#ship_killed.emit()

func _on_area2d_body_entered(body: Node2D) -> void:
	if body is fov_enemy or body is four_direc_enemy:
		print("AAAAAAAAAAAHHHHHHHHHHHHHHHHHHHH")
		var explosion = explosion_prefab.instantiate()
		explosion.position = position
		get_parent().add_child(explosion)
		queue_free()
		goblin_killed.emit()
	else:
		print("We Are Safe... For Now...")
