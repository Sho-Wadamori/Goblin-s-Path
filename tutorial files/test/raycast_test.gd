extends CharacterBody2D
class_name four_direc_enemy

## ------------------------- Variables -------------------------
@export var player: CharacterBody2D
@export var SPEED: int = 50 # Wander Speed
@export var CHASE_SPEED: int = 150 # Chase Speed
@export var ACCELERATION: int = 300 # General Acceleration
@export var wander_distance: float = 250 # Wandering Distance
@export var detection_range: float = 125 # Detection range for all directions

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # Sprite Variable
@onready var Mesh2D: MeshInstance2D = $MeshInstance2D
@onready var baseColor = $MeshInstance2D.modulate 

# Multiple raycasts for all direction
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft  
@onready var ray_cast_up: RayCast2D = $RayCastUp
@onready var ray_cast_down: RayCast2D = $RayCastDown

## Timers
@onready var chase_timer = $Chase_Timer # Timer to stop Chasing
@onready var wander_move_timer = $wander_move_timer # Timer for amount of wandering
@onready var wander_idle_timer = $wander_idle_timer # Timer for stopping in place when wandering

var direction: Vector2
var right_bounds: Vector2
var left_bounds: Vector2
var detected_direction: Vector2 # Store which direction player was detected from

enum States { WANDER, CHASE } # States the character can be in
var current_state = States.WANDER # Default State

## ------------------------- On Game Run -------------------------
func _ready():
	left_bounds = self.position + Vector2(-250, 0)
	right_bounds = self.position + Vector2(250, 0)

## ------------------------- Every Tick -------------------------
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	change_direction()
	look_for_player()
	#update_raycast_positions()
	
	## DEBUG
	if get_detection_info() == true:
		$MeshInstance2D.modulate = Color(255, 0, 0, 255)
	else:
		$MeshInstance2D.modulate = Color(0, 255, 0, 255)

### ------------------------- Set Raycast Positions -------------------------
#func update_raycast_positions():
	#ray_cast_right.position = Vector2(64, 0) # Right
	#ray_cast_left.position = Vector2(-64, 0) # Left  
	#ray_cast_up.position = Vector2(0, -64) # Up
	#ray_cast_down.position = Vector2(0, 64) # Down

## ------------------------- Look For the Player -------------------------
func look_for_player():
	var player_detected = false
	detected_direction = Vector2.ZERO

	# Force raycast updates before checking
	ray_cast_right.force_update_transform()
	ray_cast_left.force_update_transform()
	ray_cast_up.force_update_transform()
	ray_cast_down.force_update_transform()

	# Check all four directions
	if check_raycast_for_player(ray_cast_right):
		detected_direction = Vector2.RIGHT
		player_detected = true
	elif check_raycast_for_player(ray_cast_left):
		detected_direction = Vector2.LEFT
		player_detected = true
	elif check_raycast_for_player(ray_cast_up):
		detected_direction = Vector2.UP
		player_detected = true
	elif check_raycast_for_player(ray_cast_down):
		detected_direction = Vector2.DOWN
		player_detected = true
	
	if player_detected:
		chase_player()
	elif current_state == States.CHASE:
		stop_chase()

func check_raycast_for_player(raycast: RayCast2D) -> bool:
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider == player:
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

func change_direction() -> void: # moving direction
	if current_state == States.WANDER:
		if sprite.flip_h:
			# moving right
			if self.position.x <= right_bounds.x:
				direction = Vector2(1, 0)
			else:
				# flip when moving left
				sprite.flip_h = false
		else:
			# moving left
			if self.position.x >= left_bounds.x:
				direction = Vector2(-1, 0)
			else:
				# flip again when moving right
				sprite.flip_h = true
	else:
		# chase state: follow the player
		direction = (player.position - self.position).normalized()
		
		# Update sprite facing based on movement direction
		if direction.x > 0:
			sprite.flip_h = true
		elif direction.x < 0:
			sprite.flip_h = false

## ------------------------- Return To Wander -------------------------
func _on_timer_timeout(): # Return to Wander State after timeout
	current_state = States.WANDER

## ------------------------- Debug -------------------------
func get_detection_info():
	# which direction player was detected from
	if detected_direction == Vector2.RIGHT:
		return true
	elif detected_direction == Vector2.LEFT:
		return true
	elif detected_direction == Vector2.UP:
		return true
	elif detected_direction == Vector2.DOWN:
		return true
	else:
		return false









### -------------------------------------------------- PREVIOUS CODE HERE --------------------------------------------------
#extends CharacterBody2D
#
### ------------------------- Variables -------------------------
#@export var player: CharacterBody2D
#@export var SPEED: int = 50 # Wander Speed
#@export var CHASE_SPEED: int = 150 # Chase Speed
#@export var ACCELERATION: int = 300 # General Acceleration
#@export var wander_distance: float = 250 # Wandering Distance
#
#@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # Sprite Variable
#@onready var ray_cast: RayCast2D = $AnimatedSprite2D/RayCastHorizontal # ray cast Variable
#
### Timers
#@onready var chase_timer = $Chase_Timer # Timer to stop Chasing
#@onready var wander_move_timer = $WanderMoveTimer # Timer for amount of wandering
#@onready var wander_idle_timer = $WanderIdleTimer # Timer for stopping in place when wandering
#
#
#var direction: Vector2
#var right_bounds: Vector2
#var left_bounds: Vector2
#
#enum States { WANDER, CHASE } # States the character can be in
#var current_state = States.WANDER # Default State
#
### ------------------------- On Game Run -------------------------
#func _ready():
	#left_bounds = self.position + Vector2(-250, 0)
	#right_bounds = self.position + Vector2(250, 0)
#
### ------------------------- Every Tick -------------------------
#func _physics_process(delta: float) -> void:
	#handle_movement(delta)
	#change_direction()
	#look_for_player()
	#
### ------------------------- Look For the Player -------------------------
#func look_for_player():
	#if ray_cast.is_colliding():
		#var collider = ray_cast.get_collider()
		#if collider == player:
			#chase_player()
		#elif current_state == States.CHASE:
			#stop_chase()
	#elif current_state == States.CHASE:
		#stop_chase()
#
### ------------------------- Chase the Player -------------------------
#func chase_player() -> void: # Chase the player
	#chase_timer.stop()
	#current_state = States.CHASE
#
#func stop_chase() -> void: # Stop chasing the player
	#if chase_timer.time_left <= 0:
		#chase_timer.start()
#
### ------------------------- Movement -------------------------
#func handle_movement(delta: float) -> void: # Character speeds based on state
	#if current_state == States.WANDER:
		#velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	#else: 
		#velocity = velocity.move_toward(direction * CHASE_SPEED, ACCELERATION * delta)
#
	#move_and_slide()
#
#
#func change_direction() -> void: # moving direction
	#if current_state == States.WANDER:
		#if sprite.flip_h:
			## moving right
			#if self.position.x <= right_bounds.x:
				#direction = Vector2(1, 0)
			#else:
				## flip when moving left
				#sprite.flip_h = false
				#ray_cast.target_position = Vector2(-125, 0)
		#else:
			## moving left
			#if self.position.x >= left_bounds.x:
				#direction = Vector2(-1, 0)
			#else:
				## flip again when moving right
				#sprite.flip_h = true
				#ray_cast.target_position = Vector2(125, 0)
	#else:
		## chase state: follow the player
		#direction = (player.position - self.position).normalized()
		#direction = sign(direction)
		#if direction.x == 1:
			## flip to moving right
			#sprite.flip_h = true
			#ray_cast.target_position = Vector2(125, 0)
		#else:
			## flip moving to left
			#sprite.flip_h = false
			#ray_cast.target_position = Vector2(-125, 0)
#
### ------------------------- Return To Wander -------------------------
#func _on_timer_timeout(): # Return to Wander State after timeout
	#current_state = States.WANDER
