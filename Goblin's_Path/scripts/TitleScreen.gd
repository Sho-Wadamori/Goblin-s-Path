extends Control

<<<<<<< HEAD
#@onready var SceneChangeAnimation = $SceneChangeAnimation/AnimationPlayer


func _on_play_button_pressed() -> void:
	#SceneChangeAnimation.play("fade_in")
	#await get_tree().create_timer(0.5).timeout
=======

func _on_play_button_pressed() -> void:
>>>>>>> 79c4ac5822847a8cf3de488b86a1e6bb373476db
	get_tree().change_scene_to_file("res://Goblin's_Path/scenes/tutorial.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
