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
#@onready var laser_prefab = preload("res://Goblin's_Path/prefabs/laser(previous).tscn")
#@onready var explosion_prefab = preload("res://Goblin's_Path/prefabs/explosion(previous).tscn")
@onready var throw_object_prefab = preload("res://Goblin's_Path/prefabs/throwable_object.tscn")
@onready var invis_floor_prefab = preload("res://Goblin's_Path/prefabs/invisible_floor.tscn")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # Sprite Variable
@onready var silhouette = $AnimatedSprite2D2
@onready var is_sneaking: bool = false # Default is false
@export var default_speed: int = 100 # how fast the character moves
@onready var despawn_timer = $object_despawn_timer # Timer to despawn thrwn object
@onready var camera: Camera2D = get_node("Camera2D")
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var is_mobile = OS.has_feature("mobile") or OS.has_feature("HTML5")
@onready var throw_sfx = $throw

@onready var joystick = $TouchControls/TouchControlContainer/JoystickContainer/JoysStick

# sounds
@onready var footstep_sound = $"Footstep-Sound"


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
var auto_walk = false
var death_handled = false

func _ready():
	var current_scene_name = get_tree().current_scene.name
	print_debug(current_scene_name)
	#await get_tree().create_timer(1).timeout
	if current_scene_name == "Level1":
		simulate_start_walk(2)
	if current_scene_name == "Level2":
		simulate_start_walk(0.5)
	
	SettingsGlobal.checkpoint = get_tree().current_scene.scene_file_path
	
	SettingsGlobal.health_changed.connect(on_health_changed)
	
	on_health_changed(SettingsGlobal.health)

# ------------------------- Every Tick -------------------------
func _physics_process(_delta):
	movement()
	mechanics()
	update_animation()
	
	if $TouchControls.visible != SettingsGlobal.touchscreen:
		$TouchControls.visible = SettingsGlobal.touchscreen

# ------------------------- Movement -------------------------
func movement():
	if dead or throw:  # prevent movement during death or throwing
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var final_dir = Vector2.ZERO
	
	# --- Keyboard Input ---
	if auto_walk:
		final_dir.x += 1
	else:
		var keyboard_dir = Vector2.ZERO
		if Input.is_action_pressed("player_up"):
			keyboard_dir.y -= 1
		if Input.is_action_pressed("player_down"):
			keyboard_dir.y += 1
		if Input.is_action_pressed("player_left"):
			keyboard_dir.x -= 1
		if Input.is_action_pressed("player_right"):
			keyboard_dir.x += 1
		
		if keyboard_dir.length() > 0:
			final_dir = keyboard_dir.normalized()  # keyboard takes priority
		else:
			# --- Joystick Input ---
			var joystick_dir = joystick.posVector
			if joystick_dir.length() > 0:
				final_dir = joystick_dir.normalized()
	
	# Adjust speed for sneaking/sprinting
	var move_speed = default_speed
	if sneak:
		move_speed = 75
	elif sprint:
		move_speed = 200
		
	# Set velocity
	velocity = final_dir * move_speed
	direction = final_dir  # for sprite flipping
	
	# Rotate sprite based on movement
	if direction.x > 0:
		sprite.flip_h = false
		silhouette.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true
		silhouette.flip_h = true
	
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
		throw_sfx.play()
		throw_object.angular_velocity = 5.0  # radians per second; positive = clockwise
		throw_object.linear_velocity = object_direction * 500  # Adjust to change speed
		
		throw_object.position = position + object_offset
		get_parent().add_child(throw_object)
		
		# haptic feedback
		if is_mobile:
			Input.vibrate_handheld(70, 0.8)
		
		throw_object.add_to_group("ThrownObjects")
		previous_thrown_object = throw_object
		object_thrown.emit()
		throw_cooldown = true

	# ----- Sneaking Mechanics -----
	if Input.is_action_pressed("player_sneak"):
		player_sneaking.emit(true)
		SPEED = 75
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
		#print_rich("[b][color=#ffff00]DEBUG:[/color][/b][color=#ff0000] [/color][color=#ffffff][/color][color=#00ff00]PLAYER[/color][color=#ffffff] [/color][color=#ffffff]& [/color][color=#f6b26b]ENEMY[/color][color=#ffffff][/color][color=#ffffff] [/color][b][color=#ff0000]COLLIDED[/color][/b]")
		#var explosion = explosion_prefab.instantiate()
		#explosion.position = position
		#get_parent().add_child(explosion)
		dead = true
		
		# haptic feedback
		if is_mobile:
			Input.vibrate_handheld(100, 1.0)
		
		goblin_killed.emit()
		#queue_free()


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
		footstep_sound.stop()
		collision.disabled = true
		target_anim = "death"
		# Smooth zoom in on death
		if camera and camera.zoom.length() > 1.2:
			camera.zoom = camera.zoom.move_toward(Vector2(2.5, 2.5), 0.01)
		
		
	elif throw:
		target_anim = "attack"
		footstep_sound.stop()
	elif velocity.length() > 0:
		target_anim = "walk"
		if not footstep_sound.playing:
			footstep_sound.play()
		if sprint:
			target_speed = 2
		elif sneak:
			target_speed = 0.75 
	
	else:
		target_anim = "idle"
		footstep_sound.stop()
		
	if target_anim != current_anim:
		current_anim = target_anim
		sprite.play(target_anim)
		silhouette.play(target_anim)
	
	sprite.speed_scale = target_speed
	silhouette.speed_scale = target_speed
	footstep_sound.pitch_scale = 1.6 * target_speed


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "attack":
		throw = false
		throw_anim_played = false
	elif dead and sprite.animation == "death" and not death_handled:
		death_handled = true
		var tree = get_tree()
		await get_tree().create_timer(1.0).timeout
		if SettingsGlobal.health > 1:
			SettingsGlobal.change_health(SettingsGlobal.health - 1)
			tree.change_scene_to_file(SettingsGlobal.checkpoint)
			print_debug("DEBUG: Player Killed, Checkpoint")
			
		else:
			tree.change_scene_to_file("res://Goblin's_Path/scenes/GameOver.tscn")
			print_debug("DEBUG: Player Killed, Game Over")
			


func simulate_start_walk(timer):
	auto_walk = true
	if not footstep_sound.playing:
		footstep_sound.play()
	await get_tree().create_timer(timer).timeout
	auto_walk = false
	footstep_sound.stop()

## ------------------------- Sounds -------------------------
func _play_footstep():
	FootstepSoundManager.play_footstep(global_position)


## ------------------------- Mobile -------------------------
func _on_throw_button_down() -> void:
	Input.action_press("player_throw")

func _on_throw_button_up() -> void:
	Input.action_release("player_throw")

func _on_sneak_button_down() -> void:
	Input.action_press("player_sneak")

func _on_sneak_button_up() -> void:
	Input.action_release("player_sneak")

func _on_sprint_button_down() -> void:
	Input.action_press("player_speedbst")

func _on_sprint_button_up() -> void:
	Input.action_release("player_speedbst")


## ------------------------- Health -------------------------
func on_health_changed(_new_health: int): # yes there is a better way of doing this but it works
	if SettingsGlobal.health == 3:
		$Health/Control/HBoxContainer/Filled1.show()
		$Health/Control/HBoxContainer/Filled2.show()
		$Health/Control/HBoxContainer/Filled3.show()
	
	elif SettingsGlobal.health == 2:
		$Health/Control/HBoxContainer/Filled3.hide()
		$Health/Control/HBoxContainer/Empty3.show()
	elif SettingsGlobal.health == 1:
		$Health/Control/HBoxContainer/Filled3.hide()
		$Health/Control/HBoxContainer/Empty3.show()
		$Health/Control/HBoxContainer/Filled2.hide()
		$Health/Control/HBoxContainer/Empty2.show()
