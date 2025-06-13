extends Area2D

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body):
	if body.name == "player":
		body.respawn()

#flip when moving left
var velocity: Vector2 = Vector2()  # Define a velocity property
var previous_position: Vector2 = Vector2()  # Declare and initialize previous_position

func _ready():
	previous_position = global_position  # Initialize previous_position when the node is ready

func _process(delta):
	var current_position = global_position  # Get the current position
	velocity = (current_position - previous_position) / delta  # Calculate velocity
	previous_position = current_position  # Update previous_position for the next frame

	# Flip the sprite based on velocity.x
	if velocity.x < 0:
		anim.flip_h = true
	else:
		anim.flip_h = false
