extends Area2D





func _on_body_entered(body):
	print(body)
	if body.name == "Goblin":
		get_tree().change_scene_to_file("res://Goblin's_Path/scenes/Level 1.tscn")
		print("GAME COMPLETED")
