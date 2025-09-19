"""
Script for the game complete and game over screen
"""

extends Node2D

@onready var SceneChangeAnimationParent = $SceneChangeAnimation
@onready var box = $SceneChangeAnimation/Control/ColorRect

@onready var click = $ClickSound
@onready var page_flip = $page_flip

@onready var bg_music = $bg_music

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var time = SettingsGlobal.speedrun_time
	
	var minutes = int(time / 60.0)
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	var formatted_time = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
	$ScoreValue.bbcode_text = "[center]" + formatted_time
	
	SettingsGlobal.checkpoint = null
	SettingsGlobal.change_health(3)
	
	await fade_out()


func _on_play_button_pressed() -> void:
	click.play()
	
	var fade_time = 1  # seconds
	var tween = create_tween()
	tween.tween_property(bg_music, "volume_db", -80, fade_time)  # -80 dB is silence
	
	await fade_in()
	
	SettingsGlobal.speedrun_time = 0.0
	
	page_flip.play()
	await page_flip.finished
	get_tree().change_scene_to_file("res://Goblin's_Path/scenes/tutorial.tscn")
	print_debug("DEBUG: Game Restarted")


func _on_quit_button_pressed() -> void:
	click.play()
	
	var fade_time = 1  # seconds
	var tween = create_tween()
	tween.tween_property(bg_music, "volume_db", -80, fade_time)  # -80 dB is silence
	
	await fade_in()
	
	SettingsGlobal.speedrun_time = 0.0
	
	page_flip.play()
	await page_flip.finished
	get_tree().change_scene_to_file("res://Goblin's_Path/scenes/TitleScreen.tscn")
	print_debug("DEBUG: Game Quit")


func fade_in(time = 0.5) -> void:
	SceneChangeAnimationParent.show()
	box.color = Color(0, 0, 0, 0)
	var tween = create_tween()
	tween.tween_property(box, "color", Color(0, 0, 0, 1), time)
	await tween.finished

func fade_out(time = 0.5) -> void:
	SceneChangeAnimationParent.show()
	box.color = Color(0, 0, 0, 1)
	var tween = create_tween()
	tween.tween_property(box, "color", Color(0, 0, 0, 0), time)
	await tween.finished
	SceneChangeAnimationParent.hide()

func _on_ss_button_pressed() -> void:
	SettingsGlobal.save_screenshot()
