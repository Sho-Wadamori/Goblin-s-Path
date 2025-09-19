"""
Contains all settings and other variables used across the game
"""

extends Node

var enable_timer = true
var speedrun_time = 0

var fullscreen = false
var touchscreen = false

var music_volume = 0.5
var sfx_volume = 0.5

var checkpoint = null

var health = 3

@warning_ignore("unused_signal")
signal health_changed(new_health)

func change_health(value: int):
	if value != health:
		health = value
		emit_signal("health_changed", health)

func _physics_process(_delta):
	if Input.is_action_pressed("testbutton"):
		print_debug("Timer: ", enable_timer)
		print_debug("Time: ", speedrun_time)
		print_debug("FullScreen: ", fullscreen)
		print_debug("MusicV: ", music_volume)
		print_debug("SFXV: ", sfx_volume)
		print_debug("Checkpoint: ", checkpoint)
		print_debug("Health: ", health)

# Not settings but who cares
func save_screenshot() -> void:
	var folder = "user://screenshots/"
	
	# Ensure the folder exists
	var dir_access = DirAccess.open("user://")
	if not dir_access.dir_exists("screenshots"):
		dir_access.make_dir_recursive("screenshots")
	
	var dir = DirAccess.open(folder)
	
	# Find the next available number
	var number = 1
	while dir.file_exists("screenshot[%d].png" % number):
		number += 1
	
	var filename = "screenshot[%d].png" % number
	var path = folder + filename
	
	# Capture viewport and save
	var img = get_viewport().get_texture().get_image()
	var err = img.save_png(path)
	if err == OK:
		var full_path = ProjectSettings.globalize_path(path)
		print("Saved screenshot at: ", full_path)
		
		# Open the folder containing the screenshot
		var folder_path = ProjectSettings.globalize_path(folder)
		OS.shell_open(folder_path)
	else:
		print("Failed to save screenshot")
