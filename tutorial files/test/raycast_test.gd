extends CharacterBody2D

@export var player: CharacterBody2D
@export var SPEED: int = 50
@export var CHASE_SPEED: int = 150
@export var ACCELERATION: int = 300

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $AnimatedSprite2D/RayCastHorizontal
@onready var timer = $Timer








#var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2
var right_bounds: Vector2
var left_bounds: Vector2

enum States { WANDER, CHASE }
var current_state = States.WANDER

func _ready():
	left_bounds = self.position + Vector2(-250, 0)
	right_bounds = self.position + Vector2(250, 0)

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	change_direction()
	look_for_player()
	
	
func look_for_player():
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider == player:
			chase_player()
		elif current_state == States.CHASE:
			stop_chase()
	elif current_state == States.CHASE:
		stop_chase()

func chase_player() -> void:
	timer.stop()
	current_state = States.CHASE

func stop_chase() -> void:
	if timer.time_left <= 0:
		timer.start()

func handle_movement(delta: float) -> void:
	if current_state == States.WANDER:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	else: 
		velocity = velocity.move_toward(direction * CHASE_SPEED, ACCELERATION * delta)

	move_and_slide()


func change_direction() -> void:
	if current_state == States.WANDER:
		if sprite.flip_h:
			# moving right
			if self.position.x <= right_bounds.x:
				direction = Vector2(1, 0)
			else:
				# flip when moving left
				sprite.flip_h = false
				ray_cast.target_position = Vector2(-125, 0)
		else:
			# moving left
			if self.position.x >= left_bounds.x:
				direction = Vector2(-1, 0)
			else:
				# flip again when moving right
				sprite.flip_h = true
				ray_cast.target_position = Vector2(125, 0)
	else:
		# chase state: follow the player
		direction = (player.position - self.position).normalized()
		direction = sign(direction)
		if direction.x == 1:
			# flip to moving right
			sprite.flip_h = true
			ray_cast.target_position = Vector2(125, 0)
		else:
			# flip moving to left
			sprite.flip_h = false
			ray_cast.target_position = Vector2(-125, 0)











#@export var sprite
#@export var ray_cast_h
#@export var ray_cast_down
#@export var timer = $Timer

##var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
#var direction: Vector2
#var right_bounds: Vector2
#var left_bounds: Vector2
#
#enum States { WANDER, CHASE }
#var current_state = States.WANDER
#
#func _ready():
	#left_bounds = self.position + Vector2(-250, 0)
	#right_bounds = self.position + Vector2(250, 0)
#
#func _physics_process(delta: float) -> void:
	#handle_gravity(delta)
	#handle_movement(delta)
	#change_direction()
	#look_for_player()
	#
	#
#func look_for_player():
	#if ray_cast_h.is_colliding():
		#var collider = ray_cast_h.get_collider()
		#if collider == player:
			#chase_player()
		#elif current_state == States.CHASE:
			#stop_chase()
	#elif current_state == States.CHASE:
		#stop_chase()
#
#func chase_player() -> void:
	#timer.stop()
	#current_state = States.CHASE
#
#func stop_chase() -> void:
	#if timer.time_left <= 0:
		#timer.start()
#
#func handle_movement(delta: float) -> void:
	#if current_state == States.WANDER:
		#velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	#else: 
		#velocity = velocity.move_toward(direction * CHASE_SPEED, ACCELERATION * delta)
#
	#move_and_slide()
#
#
#func change_direction() -> void:
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
			#ray_cast.target_position = Vector2(-125, 0)
		#else:
			## flip moving to left
			#sprite.flip_h = false
			#ray_cast.target_position = Vector2(-125, 0)







	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction = Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()


func _on_timer_timeout():
	current_state = States.WANDER
