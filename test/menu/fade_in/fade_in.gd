extends ColorRect

signal fade_finished

func fade_in():
	$AnimationPlayer.play("fade_in")

func _on_animation_player_animation_finished(_anim_name):
	emit_signal("fade_finished")
