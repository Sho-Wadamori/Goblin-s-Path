extends Area2D


@onready var SceneChangeAnimation = $"../SceneChangeAnimation/AnimationPlayer"
@onready var TimerAnim = $"../YSorting/Goblin/Timer/AnimationPlayer"
@onready var bg_music = $"../bg_music"


func _on_body_entered(body):
	print_rich("[b][color=#ffff00]DEBUG:[/color][/b][color=#ff0000] [/color][color=#00ff00]PORTAL ENTER [color=#ff0000]DETECTED[/color][/color] - ", body)
	if body.name == "Goblin":
		var fade_time = 1  # seconds
		var tween = create_tween()
		tween.tween_property(bg_music, "volume_db", -80, fade_time)  # -80 dB is silence
		SceneChangeAnimation.play("fade_in")
		TimerAnim.play("TimerFadeOut")
		await SceneChangeAnimation.animation_finished
		await tween.finished
		get_tree().call_deferred("change_scene_to_file", "res://Goblin's_Path/scenes/Level 1.tscn")
		print("DEBUG: Tutorial Completed")
