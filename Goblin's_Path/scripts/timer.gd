extends CanvasLayer

var time = 0.0

func _ready():
	# Restore global time when entering a new scene
	time = SettingsGlobal.speedrun_time

func _physics_process(delta):
	time += delta
	SettingsGlobal.speedrun_time = time  # keep numeric global
	update_ui()

func update_ui():
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	var formatted_time = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

	$Label.text = formatted_time
