extends Control

func _on_Button_pressed():
	$UISound.play()
	$FadeIn.show()
	$FadeIn.fade_in()

func _on_CheckBox_pressed():
	#$UISound.play()
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED

func _on_fade_in_fade_finished():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file("res://Menu/Main Menu.tscn")

func _ready():
	set_process(true)

func _process(_delta):
	if Input.is_action_pressed("key_exit"):
		$FadeIn.show()
		$FadeIn.fade_in()

func _on_Music_Slider_value_changed(value):
	AudioServer.set_bus_volume_db(1, lerp(AudioServer.get_bus_volume_db(1), value, 0.5))
	if value == -30:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)

func _on_Game_Slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, lerp(AudioServer.get_bus_volume_db(2), value, 0.5))
	if value == -30:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
