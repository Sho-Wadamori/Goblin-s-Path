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
@onready var throw_object_prefab = preload("res://Goblin's_Path/prefabs/throwable_object.tscn")
@onready var invis_floor_prefab = preload("res://Goblin's_Path/prefabs/invisible_floor.tscn")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # Sprite Variable
@onready var silhouette = $AnimatedSprite2D2
@onready var is_sneaking: bool = false # Default is false
@export var default_speed: int = 100 # how fast the character moves
@onready var despawn_timer = $object_despawn_timer # Timer to despawn thrwn object
@onready var camera: Camera2D = get_node("Camera2D")

var SPEED = 50
var direction: Vector2
var previous_thrown_object: Node2D = null
var previous_invis_floor: Node2D = null
var throw_cooldown = false

var dead = false
var death_anim_played = false
var sprint = false
var sneak = false
var throw = false
var throw_anim_played = false
var current_anim = ""

# ------------------------- Every Tick -------------------------
func _physics_process(_delta):
	movement()
	mechanics()
	update_animation()

# ------------------------- Movement -------------------------
func movement():
	if dead or throw:  # <- prevent movement during death or throwing
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
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
		direction = input_direction
	# velocity calculation
	velocity = input_direction * SPEED
	
	# Rotate Sprite to face movement direction
	# Update sprite facing based on movement direction
	if direction.x > 0:
		sprite.flip_h = false
		silhouette.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true
		silhouette.flip_h = true

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
	if Input.is_action_just_pressed("player_throw") and not throw_cooldown:
		# --- delete previous ones if they exist ---
		if previous_thrown_object and previous_thrown_object.is_inside_tree():
			previous_thrown_object.queue_free()
		if previous_invis_floor and previous_invis_floor.is_inside_tree():
			previous_invis_floor.queue_free()
			
		despawn_timer.start()
		throw = true
		# --- instantiate floor ---
		var floor_offset = Vector2(0, 10)
		var invis_floor = invis_floor_prefab.instantiate()
		invis_floor.position = position + floor_offset
		get_parent().add_child(invis_floor)
		previous_invis_floor = invis_floor
		
		# --- instantiate object ---
		var angle_degrees = 0
		var object_offset = Vector2(0, 0)
		
		if sprite.flip_h == false:
			angle_degrees = -30
			object_offset = Vector2(30, 0) #give it an offset
		else:
			angle_degrees = -150
			object_offset = Vector2(-30, 0) #give it an offset
		
		# Give it velocity in a fixed direction — 30 degrees
		var angle_radians = deg_to_rad(angle_degrees)
		var object_direction = Vector2(1, 0).rotated(angle_radians)
		
		# make the object
		var throw_object = throw_object_prefab.instantiate()
		
		throw_object.angular_velocity = 5.0  # radians per second; positive = clockwise
		throw_object.linear_velocity = object_direction * 500  # Adjust to change speed
		
		throw_object.position = position + object_offset
		get_parent().add_child(throw_object)
		throw_object.add_to_group("ThrownObjects")
		previous_thrown_object = throw_object
		object_thrown.emit()
		throw_cooldown = true

	# ----- Sneaking Mechanics -----
	if Input.is_action_pressed("player_sneak"):
		player_sneaking.emit(true)
		SPEED = 40
		sneak = true
	elif Input.is_action_pressed("player_speedbst"):
		SPEED = 200
		sprint = true
	else:
		player_sneaking.emit(false)
		SPEED = default_speed
		sprint = false
		sneak = false



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
		print_rich("[b][color=#ffff00]DEBUG:[/color][/b][color=#ff0000] [/color][color=#ffffff][/color][color=#00ff00]PLAYER[/color][color=#ffffff] [/color][color=#ffffff]& [/color][color=#f6b26b]ENEMY[/color][color=#ffffff][/color][color=#ffffff] [/color][b][color=#ff0000]COLLIDED[/color][/b]")
		#var explosion = explosion_prefab.instantiate()
		#explosion.position = position
		#get_parent().add_child(explosion)
		dead = true
		goblin_killed.emit()
		#queue_free()
		
	else:
		print_rich("[b][color=#ffff00]DEBUG:[/color][/b][color=#ff0000] [/color][color=#00ff00]PLAYER[/color][color=#ffffff] [/color][color=#ffffff]& [/color][color=#00ffff]WALL [/color][b][color=#ff0000]COLLIDED[/color][/b]")


func _on_object_despawn_timer_timeout() -> void:
	previous_thrown_object.queue_free()
	previous_invis_floor.queue_free()
	previous_thrown_object = null
	previous_invis_floor = null
	throw_cooldown = false

## ------------------------- Animations -------------------------
func update_animation():
	var target_anim = ""
	var target_speed = 1
	if dead:
		target_anim = "death"
		# Smooth zoom in on death
		if camera and camera.zoom.length() > 1.2:
			camera.zoom = camera.zoom.move_toward(Vector2(2.5, 2.5), 0.01)
	elif throw:
		target_anim = "attack"
	elif velocity.length() > 0:
		target_anim = "walk"
		if sprint:
			target_speed = 2
	else:
		target_anim = "idle"
	if target_anim != current_anim:
		current_anim = target_anim
		sprite.play(target_anim)
		silhouette.play(target_anim)
	
	sprite.speed_scale = target_speed
	silhouette.speed_scale = target_speed
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "attack":
		throw = false
		throw_anim_played = false
	elif dead and sprite.animation == "death":
		var tree = get_tree()
		await get_tree().create_timer(1.0).timeout
		tree.change_scene_to_file("res://Goblin's_Path/scenes/GameOver.tscn")
		print("DEBUG: Player Killed")
