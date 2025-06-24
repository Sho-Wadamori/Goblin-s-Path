extends CharacterBody2D
class_name fov_enemy

## ------------------------- Variables -------------------------
@export var player: CharacterBody2D
@export var SPEED: int = 50 # Wander Speed
@export var CHASE_SPEED: int = 150 # Chase Speed
@export var ACCELERATION: int = 300 # General Acceleration
@export var wander_distance: float = 250 # Wandering Distance
@export var detection_range: float = 125 # Detection range for all directions
@export var wander_change_interval: float = 2.0 # How often to change wander direction (seconds)
@export var wander_angle_change: float = 30.0 # Max angle change when wandering (degrees) - reduced for smoother turning
@export var wander_walk_time: float = 5.0 # Time to walk before stopping
@export var wander_idle_time: float = 2.0 # Time to idle before walking again

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # Sprite Variable
@onready var Mesh2D: MeshInstance2D = $MeshInstance2D
@onready var baseColor = $MeshInstance2D.modulate
@onready var bitmap: Node2D = $Bitmap 

# Multiple raycasts for all direction
@onready var ray_cast_1: RayCast2D = $Bitmap/RayCast1
@onready var ray_cast_2: RayCast2D = $Bitmap/RayCast2  
@onready var ray_cast_3: RayCast2D = $Bitmap/RayCast3
@onready var ray_cast_4: RayCast2D = $Bitmap/RayCast4
@onready var ray_cast_5: RayCast2D = $Bitmap/RayCast5

## Timers
@onready var chase_timer = $Chase_Timer # Timer to stop Chasing
@onready var wander_move_timer = $wander_move_timer # Timer for amount of wandering
@onready var wander_idle_timer = $wander_idle_timer # Timer for stopping in place when wandering

var direction: Vector2
var wander_direction: Vector2 # Current wandering direction
var spawn_position: Vector2 # Starting position for boundary checking
var wander_angle: float = 0.0 # Current wander angle in radians
var wander_timer: float = 0.0 # Timer for walk/idle cycle
var is_wandering: bool = true # Whether currently walking or idling

enum States { WANDER, CHASE } # States the character can be in
enum WanderState { WALKING, IDLE } # Sub-states for wandering
var current_state = States.WANDER # Default State
var wander_state = WanderState.WALKING # Default wander sub-state

## ------------------------- On Game Run -------------------------
func _ready():
	spawn_position = self.position
	# Start with a random direction
	wander_angle = randf() * 2 * PI
	wander_direction = Vector2(cos(wander_angle), sin(wander_angle))
	direction = wander_direction


func _on_goblin_player_sneaking(is_sneaking):	# If sneaking
	if is_sneaking:
		print("Player is sneaking")
		bitmap.set_scale(Vector2(1.227, 1.227))

	else:
		print("Player stopped sneaking")
		bitmap.set_scale(Vector2(1.862, 1.862))


## ------------------------- Every Tick -------------------------
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	change_direction(delta)
	look_for_player()
	update_raycast_positions()
	# This print should tell you what the scale is *after* all other _physics_process logic
	print("Bitmap scale at end of _physics_process: ", bitmap.scale)

## ------------------------- Set Raycast Positions -------------------------
func update_raycast_positions():
	# Rotate bitmap to face movement direction
	if direction.length() > 0:
		bitmap.rotation = direction.angle()
		
		# Update sprite facing based on movement direction
		if direction.x > 0:
			sprite.flip_h = true
		elif direction.x < 0:
			sprite.flip_h = false

## ------------------------- Look For the Player -------------------------
func look_for_player():
	var player_detected = false

	# Error Message
	if not ray_cast_1 or not ray_cast_2 or not ray_cast_3 or not ray_cast_4 or not ray_cast_5:
		print("Error: Path isnt working :(")
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
	
	if player_detected:
		chase_player()

	elif current_state == States.CHASE:
		stop_chase()

func check_raycast_for_player(raycast: RayCast2D) -> bool:
	if raycast and raycast.enabled and raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and collider == player:
			return true
	return false

## ------------------------- Chase the Player -------------------------
func chase_player() -> void: # Chase the player
	chase_timer.stop()
	current_state = States.CHASE

func stop_chase() -> void: # Stop chasing the player
	if chase_timer.time_left <= 0:
		chase_timer.start()

## ------------------------- Movement -------------------------
func handle_movement(delta: float) -> void: # Character speeds based on state
	if current_state == States.WANDER:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	else: 
		velocity = velocity.move_toward(direction * CHASE_SPEED, ACCELERATION * delta)
	move_and_slide()
	
	# Check if hit a wall while wandering
	if current_state == States.WANDER and wander_state == WanderState.WALKING:
		if get_slide_collision_count() > 0:
			#print("Hit wall!") # DEBUG
			change_wander_direction()

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
	else:
		# chase state: follow the player
		direction = (player.position - self.position).normalized()

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
