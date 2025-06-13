extends Node2D


func _on_button_pressed():
	get_tree().change_scene_to_file("res://2d_simple_game/scenes/level_1.tscn")



func _on_button_3_pressed():
	get_tree().change_scene_to_file("res://2d_space_shooter/scenes/space_shooter.tscn")
