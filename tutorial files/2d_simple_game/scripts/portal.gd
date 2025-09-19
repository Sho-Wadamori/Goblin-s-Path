extends Area2D

@onready var SceneChangeAnimationParent = $"../SceneChangeAnimation"
@onready var box = $"../SceneChangeAnimation/Control/ColorRect"
@onready var timer_label = $"../YSorting/Goblin/Timer/Label"
@onready var hearts = $"../YSorting/Goblin/Health/Control"
@onready var bg_music = $"../bg_music"

func _on_body_entered(body):
	print_rich("[b][color=#ffff00]DEBUG:[/color][/b][color=#ff0000] [/color][color=#00ff00]PORTAL ENTER [color=#ff0000]DETECTED[/color][/color] - ", body)
	if body.name == "Goblin":
		music_fade()
		
		fade_out_heart()
		fade_out_timer()
		await fade_in()
		
		await get_tree().create_timer(0.1).timeout
		get_tree().call_deferred("change_scene_to_file", "res://Goblin's_Path/scenes/Level 1.tscn")
		print_debug("DEBUG: Tutorial Completed")

func music_fade():
	var fade_time = 1  # seconds
	var tween = create_tween()
	tween.tween_property(bg_music, "volume_db", -80, fade_time)  # -80 dB is silence

func fade_in(time = 0.5) -> void:
	SceneChangeAnimationParent.show()
	box.color = Color(0, 0, 0, 1)
	box.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(box, "modulate:a", 1.0, time)
	await tween.finished

func fade_out_timer():
	var tween = create_tween()
	tween.tween_property(timer_label, "modulate:a", 0.0, 1.0)
	await tween.finished

func fade_out_heart():
	var tween = create_tween()
	tween.tween_property(hearts, "modulate:a", 0.0, 1.0)
	await tween.finished
