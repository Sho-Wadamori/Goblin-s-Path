"""
Script for the controlable goblin character
Includes:
	- Basic WASD and arrow key movement
	- Reduction of speed when sneaking
	- Signaling Death
	- Damage/death on contact with enemies
	- Throwing objects
"""
# ------------------------- General Settings -------------------------
extends CharacterBody2D
class_name goblin

# ------------------------- Global Variables -------------------------
signal goblin_killed
signal player_sneaking(is_sneaking: bool) # currently not using this
signal object_thrown

# ------------------------- Variables -------------------------
@onready var laser_prefab = preload("res://Goblin's_Path/prefabs/laser(previous).tscn")
@onready var explosion_prefab = preload("res://Goblin's_Path/prefabs/explosion(previous).tscn")
@onready var throw_object_prefab = preload("res://Goblin's_Path/prefabs/throwable_object.tscn")
@onready var invis_floor_prefab = preload("res://Goblin's_Path/prefabs/invisible_floor.tscn")

@onready var is_sneaking: bool = false # Default is false
@export var SPEED: int = 50 # how fast the character moves

var previous_thrown_object: Node2D = null
var previous_invis_floor: Node2D = null

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
	## ----- Shooting Mechanics -----
	#if Input.is_action_just_pressed("player_throw"):
		## make a laser
		#var laser = laser_prefab.instantiate()
		#laser.position = position
		#get_parent().add_child(laser)
	
	# ----- Throwing Mechanics -----
	if Input.is_action_just_pressed("player_throw"):
		# --- delete previous ones if they exist ---
		if previous_thrown_object and previous_thrown_object.is_inside_tree():
			previous_thrown_object.queue_free()
		if previous_invis_floor and previous_invis_floor.is_inside_tree():
			previous_invis_floor.queue_free()
		
		# --- instantiate floor ---
		var floor_offset = Vector2(0, 10)
		var invis_floor = invis_floor_prefab.instantiate()
		invis_floor.position = position + floor_offset
		get_parent().add_child(invis_floor)
		previous_invis_floor = invis_floor
		
		# --- instantiate object ---
		# Give it velocity in a fixed direction — 30 degrees
		var angle_degrees = -30
		var angle_radians = deg_to_rad(angle_degrees)
		var direction = Vector2(1, 0).rotated(angle_radians)
		#give it an offset
		var object_offset = Vector2(30, 0)
		
		# make the object
		var throw_object = throw_object_prefab.instantiate()
		
		throw_object.angular_velocity = 5.0  # radians per second; positive = clockwise
		throw_object.linear_velocity = direction * 500  # Adjust to change speed
		
		throw_object.position = position + object_offset
		get_parent().add_child(throw_object)
		throw_object.add_to_group("ThrownObjects")
		previous_thrown_object = throw_object
		object_thrown.emit()

	# ----- Sneaking Mechanics -----
	if Input.is_action_pressed("player_sneak"):
		player_sneaking.emit(true)
		SPEED = 40
	elif Input.is_action_pressed("player_speedbst"):
		SPEED = 200
	else:
		player_sneaking.emit(false)
		SPEED = 120

	# ----- Distracting Mechanics -----
	


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
		print("DEBUG: Player & enemy collided")
		var explosion = explosion_prefab.instantiate()
		explosion.position = position
		get_parent().add_child(explosion)
		queue_free()
		goblin_killed.emit()
	else:
		print("DEBUG: Player collided with wall")
