extends Node

var enable_timer = true
var speedrun_time = 0

var fullscreen = false
var touchscreen = false

var music_volume = 0.5
var sfx_volume = 0.5

func _physics_process(delta):
	if Input.is_action_pressed("testbutton"):
		print(enable_timer)
		print(speedrun_time)
		print(fullscreen)
		print(music_volume)
		print(sfx_volume)
