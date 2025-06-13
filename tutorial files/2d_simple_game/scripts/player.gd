extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -600.0
const DASH_SPEED = 900.0
var dashing = false
var can_dash = true
#jump count
var jump_count = 0
var max_jumps = 2

var start_position = Vector2(600, 300)

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
		if abs(velocity.x) > 10:
			anim.play("run")
			
		else:
			anim.play("idle")
			
	if velocity.x < 0:
		anim.flip_h = true
	else:
		anim.flip_h = false
			
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jumps:
		print("Jump pressed!")  
		velocity.y = JUMP_VELOCITY
		anim.play("jump")
		jump_count += 1
	if Input.is_action_just_pressed("player_dash") and can_dash:
		dashing = true
		can_dash = false
		$dash_timer.start()
		$dash_cooldown.start()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("player_back", "player_forwards")
	if direction:
		if dashing:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	#respawn
	if position.y > 1500:
		position = start_position
		respawn()

func respawn():
	position = start_position

func _on_dash_timer_timeout():
	dashing = false

func _on_dash_cooldown_timeout():
	can_dash = true
