"""
Script for the enemy with field of view
Includes:
	- Player Interaction:
		- Look for player with raycasts
		- Chasing Player
		- Changes in field of view if player is sneaking
	- Movement:
		- Wandering in any direction
		- Pauses when wandering
		- Wandering nearby their spawning point
		- Changes in speed depending on state
		- Bouncing off walls to avoid getting stuck
	- inspection:
		- inspect items thrown by the player
		- stop to inspect thrown object
		- increase FOV when inspecting
		- make chasing prioritised over inspecting
"""

extends CharacterBody2D
class_name fov_enemy_test

## ------------------------- Variables -------------------------
@export var player: CharacterBody2D
@export var SPEED: int = 50 # Wander Speed
@export var CHASE_SPEED: int = 150 # Chase Speed
@export var ACCELERATION: int = 300 # General Acceleration
@export var wander_distance: float = 250 # Wandering Distance
@export var detection_range: float = 125 # Detection range for all directions
# Wandering State
@export var wander_change_interval: float = 2.0 # How often to change wander direction (seconds)
@export var wander_angle_change: float = 60.0 # Max angle change when wandering (degrees)
@export var wander_walk_time: float = 5.0 # Time to walk before stopping
@export var wander_idle_time: float = 2.0 # Time to idle before walking again
# Inspection State
@export var object_to_chase: Node2D = null  # assign in inspector or dynamically
@export var object_chase_range: float = 200.0 # how close to start chasing object
@export var inspect_stop_distance: float = 40.0 # Distance to stop when inspecting object

## Node References
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # Sprite Variable
@onready var bitmap: Node2D = $Bitmap # Bitmap reference, contains all raycasts

## All Raycasts
@onready var ray_cast_1: RayCast2D = $Bitmap/RayCast1
@onready var ray_cast_2: RayCast2D = $Bitmap/RayCast2  
@onready var ray_cast_3: RayCast2D = $Bitmap/RayCast3
@onready var ray_cast_4: RayCast2D = $Bitmap/RayCast4
@onready var ray_cast_5: RayCast2D = $Bitmap/RayCast5

## All Timers
@onready var chase_timer = $Chase_Timer # Timer to stop Chasing
@onready var wander_move_timer = $wander_move_timer # Timer for amount of wandering
@onready var wander_idle_timer = $wander_idle_timer # Timer for stopping in place when wandering
@onready var inspect_timer = $inspect_timer # Timer for how long to inspect

## State & Movement
var direction: Vector2
var spawn_position: Vector2 # Starting position for boundary checking
var is_player_sneaking: bool = false  # Player sneaking state
var view_range: Vector2 = Vector2(1.862, 1.862) # Scale of view range
# States
enum States { WANDER, CHASE, INSPECT } # States the character can be in
var current_state = States.WANDER # Default State
# wandering
var is_wandering: bool = true # Whether currently walking or idling
var wander_direction: Vector2 # Current wandering direction
var wander_angle: float = 0.0 # Current wander angle in radians
var wander_timer: float = 0.0 # Timer for walk/idle cycle
var wander_state = WanderState.WALKING # Default wander sub-state
enum WanderState { WALKING, IDLE } # Sub-states for wandering
# Inspection
var object_detected = false # Whether the enemy already inspected current object
var is_close_to_inspect_object: bool = false # Whether enemy is close enough to inspecting object


## ------------------------- On Game Run -------------------------
var enemy_id: int = 0
static var enemy_counter: int = 0
func _ready():
	enemy_counter += 1
	enemy_id = enemy_counter
	
	
	spawn_position = self.position
	# Start with a random direction
	wander_angle = randf() * 2 * PI
	wander_direction = Vector2(cos(wander_angle), sin(wander_angle))
	direction = wander_direction
	object_detected = false	
	print("Enemy ", enemy_id, " created at position ", position)

## ------------------------- Every Tick -------------------------
func _physics_process(delta: float) -> void:
	change_direction(delta)
	handle_movement(delta)
	move_and_slide()
	
	look_for_player()
	
	if current_state != States.CHASE:
		look_for_object()
	
	update_raycast_positions()
	change_view_distance()


## ------------------------- Set Raycast Positions -------------------------
func update_raycast_positions():
	# Rotate bitmap to face movement direction
	if direction.length() > 0:
		bitmap.rotation = direction.angle()
		
		# Update sprite facing based on movement direction
		if direction.x > 0:
			sprite.flip_h = false
		elif direction.x < 0:
			sprite.flip_h = true


## ------------------------- Look For the Object -------------------------
func _on_goblin_object_thrown() -> void:
	object_detected = false
	print("Enemy ", enemy_id, " received object_thrown signal, reset object_detected to false")
	print_rich("[b][color=#ffff00]DEBUG:[/color][/b][color=#ff0000] [/color][color=#ffffff]NEW[/color] [color=#00ffff]OBJECT[/color][color=#00ffff] [color=#ff0000][b]THROWN[/b][/color][/color]")

func get_thrown_object() -> Node2D:
	var thrown_objects = get_tree().get_nodes_in_group("ThrownObjects")
	if thrown_objects.size() > 0:
		return thrown_objects[0]
	return null

func look_for_object():
	var new_object = get_thrown_object()
	
	if new_object and is_instance_valid(new_object) and not object_detected:
		var dist = position.distance_to(new_object.position)
		if dist <= object_chase_range and current_state != States.CHASE and not object_detected:
			object_to_chase = new_object
			current_state = States.INSPECT
			
			# start inspect timer (ONLY IF NOT ALREADY STARTED)
			if inspect_timer.time_left == 0:
				print("Starting inspect timer with wait_time: ", inspect_timer.wait_time)
				inspect_timer.start()
				print("Timer started, time_left: ", inspect_timer.time_left)
				print_rich("[b][color=#ffff00]DEBUG:[/color][/b][color=#ff0000] [/color][color=#ff0000]ENEMY[/color][color=#ff0000][b] [/b][/color][color=#ff0000][b]SWITCHED [/b][/color][color=#ffffff][b]TO [/b][/color][color=#00ff00][b]INSPECT STATE[/b][/color]")
				bitmap.set_scale(Vector2(2.4, 2.4))

func _on_inspect_timer_timeout():
	current_state = States.WANDER
	is_close_to_inspect_object = false
	change_wander_direction()
	print_rich("[b][color=#ffff00]DEBUG:[/color][/b][color=#ff0000] FINISHED [/color][color=#00ff00]INSPECTING[/color][color=#ff0000], [/color][color=#ffffff]RETURNING TO [/color][color=#00ff00]WANDER STATE[/color][color=#ff0000] [/color]")
	object_detected = true
	
	# Reset bitmap scale to normal wander view
	if is_player_sneaking:
		view_range = Vector2(1.227, 1.227)
	else:
		view_range = Vector2(1.862, 1.862)
	bitmap.set_scale(view_range)

## ------------------------- Look For the Player -------------------------
func look_for_player():
	var player_detected = false

	# Error Message
	if not ray_cast_1 or not ray_cast_2 or not ray_cast_3 or not ray_cast_4 or not ray_cast_5:
		print_rich("[b]ERROR: PATH NOT WORKING :([/b][/color]")
		return

	# Force raycast update
	ray_cast_1.force_raycast_update()
	ray_cast_2.force_raycast_update()
	ray_cast_3.force_raycast_update()
	ray_cast_4.force_raycast_update()
	ray_cast_5.force_raycast_update()

	# Check all directions
	if check_raycast_for_player(ray_cast_1):
		player_detected = true
	elif check_raycast_for_player(ray_cast_2):
		player_detected = true
	elif check_raycast_for_player(ray_cast_3):
		player_detected = true
	elif check_raycast_for_player(ray_cast_4):
		player_detected = true
	
	if player_detected: # chase if player is detected
		object_to_chase = null  # stop inspecting object
		bitmap.set_scale(Vector2(2.4, 2.4))
		chase_player()
		print_rich("[b][color=#ffff00]DEBUG:[/color][/b][color=#ff0000] [/color][color=#00ff00]PLAYER[color=#ff0000] DISCOVERED[/color][/color]")

	elif current_state == States.CHASE:
		stop_chase() # stop chase

func check_raycast_for_player(raycast: RayCast2D) -> bool:
	if raycast and raycast.enabled and raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and collider == player:
			return true
	return false


## ------------------------- Chase the Player -------------------------
func chase_player() -> void: # Chase the player
	chase_timer.stop()
	inspect_timer.stop()
	current_state = States.CHASE

func stop_chase() -> void: # Stop chasing the player
	if chase_timer.time_left <= 0:
		chase_timer.start()
		print("DEBUG: Player out of view")


## ------------------------- Movement -------------------------
func handle_movement(delta: float) -> void: # Character speeds based on state
	if current_state == States.WANDER:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	elif current_state == States.CHASE: 
		velocity = velocity.move_toward(direction * CHASE_SPEED, ACCELERATION * delta)
	elif current_state == States.INSPECT:
		# only move if not close to object
		if is_close_to_inspect_object: 
			velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION * delta)
		else:
			velocity = velocity.move_toward(direction * CHASE_SPEED, ACCELERATION * delta)
			
	# Check if hit a wall while wandering
	if current_state == States.WANDER and wander_state == WanderState.WALKING:
		if get_slide_collision_count() > 0:
			change_wander_direction() # change direction if colliding with wall

func change_direction(delta: float) -> void: # moving direction
	if current_state == States.WANDER:
		# Update wander timer
		wander_timer += delta
		
		# Handle walk/idle cycle
		if wander_state == WanderState.WALKING:
			if wander_timer >= wander_walk_time:
				# Switch to idle
				wander_state = WanderState.IDLE
				wander_timer = 0.0
				direction = Vector2.ZERO # Stop moving
		else: # WanderState.IDLE
			if wander_timer >= wander_idle_time:
				# Switch to walking with new direction
				wander_state = WanderState.WALKING
				wander_timer = 0.0
				change_wander_direction()
		
		# Only move if in walking state
		if wander_state == WanderState.WALKING:
			# Check boundaries and adjust direction if needed
			var distance_from_spawn = spawn_position.distance_to(self.position)
			if distance_from_spawn > wander_distance:
				# Turn towards spawn point
				var to_spawn = (spawn_position - self.position).normalized()
				wander_direction = to_spawn
				wander_angle = to_spawn.angle()
			
			direction = wander_direction
	
	elif current_state == States.CHASE:
		# chase state: follow the player
		direction = (player.global_position - self.global_position).normalized()
	
	elif current_state == States.INSPECT:
		if object_to_chase and is_instance_valid(object_to_chase) and current_state != States.CHASE:
			var distance_to_object = position.distance_to(object_to_chase.position)
			# Check if close enough to stop moving
			if distance_to_object <= inspect_stop_distance:
				if not is_close_to_inspect_object:
					is_close_to_inspect_object = true
					print_rich("[b][color=#ffff00]DEBUG:[/color][/b][color=#00ff00] CLOSE ENOUGH TO OBJECT, STOPPING MOVEMENT[/color]")
				direction = Vector2.ZERO # Stop moving toward object
			else:
				direction = (object_to_chase.position - position).normalized()
		else:
			# Object disappeared, return to wander
			current_state = States.WANDER
			is_close_to_inspect_object = false
			change_wander_direction()
			# Reset bitmap scale when object disappears
			if is_player_sneaking:
				view_range = Vector2(1.227, 1.227)
			else:
				view_range = Vector2(1.862, 1.862)
			bitmap.set_scale(view_range)

func change_wander_direction():
	# Change angle by a random amount within the specified range (smoother turning)
	var angle_change = (randf() - 0.5) * 2 * deg_to_rad(wander_angle_change)
	wander_angle += angle_change
	
	# Create new direction vector
	wander_direction = Vector2(cos(wander_angle), sin(wander_angle))


## ------------------------- Return To Wander -------------------------
func _on_timer_timeout(): # Return to Wander State after timeout
	current_state = States.WANDER
	wander_state = WanderState.WALKING
	wander_timer = 0.0
	# Reset wander direction when returning from chase
	change_wander_direction()


## -------------------------  Change View Distance -------------------------
func change_view_distance():	# If sneaking
	# Only do something if the state actually changed
	var is_sneaking = Input.is_action_pressed("player_sneak")
	if is_sneaking != is_player_sneaking:
		is_player_sneaking = is_sneaking
		if current_state == States.INSPECT or current_state == States.CHASE:
			view_range = Vector2(2.4, 2.4)
		elif is_sneaking:
			print("DEBUG: Player is sneaking")
			view_range = Vector2(1.227, 1.227)
		else:
			print("DEBUG: Player stopped sneaking")
			view_range = Vector2(1.862, 1.862)
		bitmap.set_scale(view_range)
