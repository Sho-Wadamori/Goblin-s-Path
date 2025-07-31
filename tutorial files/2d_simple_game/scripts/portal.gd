extends Area2D


@onready var SceneChangeAnimation = $"../SceneChangeAnimation/AnimationPlayer"



func _on_body_entered(body):
	print_rich("[b][color=#ffff00]DEBUG:[/color][/b][color=#ff0000] [/color][color=#00ff00]PORTAL ENTER [color=#ff0000]DETECTED[/color][/color] - ", body)
	if body.name == "Goblin":
		SceneChangeAnimation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Goblin's_Path/scenes/Level 1.tscn")
		print("DEBUG: Tutorial Completed")
