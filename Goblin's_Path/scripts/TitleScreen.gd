extends Control

#@onready var SceneChangeAnimation = $SceneChangeAnimation/AnimationPlayer


func _on_play_button_pressed() -> void:
	#SceneChangeAnimation.play("fade_in")
	#await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Goblin's_Path/scenes/tutorial.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
