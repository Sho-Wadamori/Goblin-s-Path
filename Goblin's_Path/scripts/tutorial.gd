extends Node2D

#in charge of keeping score and spawning enemies
#@onready var enemy_prefab = preload("res://Goblin's_Path/prefabs/enemy(previous).tscn")

@export var on_screen_pos = Vector2(0, -340)
@export var off_screen_pos = Vector2(370, -340)

@onready var SceneChangeAnimationParent = $SceneChangeAnimation
@onready var box = $SceneChangeAnimation/Control/ColorRect
@onready var timer_label = $YSorting/Goblin/Timer/Label
@onready var hearts = $YSorting/Goblin/Health/Control
@onready var level_intro = $YSorting/Goblin/LevelIntro/CenterContainer
@onready var package = $YSorting/package
var score = 0
var toast_shown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#_update_ui()
	
	## tween 1st time doesn't work 4 some reason
	var Runtween = create_tween()
	$toastNotification/Control.position = off_screen_pos
	$toastNotification/Control.modulate.a = 0.0
	Runtween.tween_property($toastNotification/Control, "position", on_screen_pos, 0.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Runtween.tween_interval(0.0)
	Runtween.tween_property($toastNotification/Control, "position", off_screen_pos, 0.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	$toastNotification/Control.modulate.a = 1.0
	
	await fade_out(1.5)
	
	fade_in_timer()
	fade_in_heart()
	
	level_intro.modulate.a = 0.0
	await fade_level_intro()
	
	SettingsGlobal.speedrun_time = 0.0

#func _update_ui():
	#$game_UI/score_label.text = "SCORE: " + str(score)

#func _on_enemy_killed():
	#score += 50
	#_update_ui()

#func _on_restart_timer_timeout():
	#get_tree().reload_current_scene()


func fade_out(time = 0.5) -> void:
	SceneChangeAnimationParent.show()
	box.color = Color(0, 0, 0, 1)
	var tween = create_tween()
	tween.tween_property(box, "modulate:a", 0, time)
	await tween.finished
	SceneChangeAnimationParent.hide()

func fade_in_timer():
	timer_label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(timer_label, "modulate:a", 1.0, 1.0)

func fade_in_heart():
	hearts.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(hearts, "modulate:a", 1.0, 1.0)

func fade_level_intro():
	# Start fully transparent
	level_intro.modulate.a = 0.0
	
	var tween = create_tween()
	
	tween.tween_property(level_intro, "modulate:a", 1.0, 1.0)
	tween.tween_interval(2.0)
	tween.tween_property(level_intro, "modulate:a", 0.0, 1.0)
	
	await tween.finished


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name != "Goblin" or toast_shown:
		return
	
	toast_shown = true
	$YSorting/package.monitoring = false
	
	var tween = create_tween()
	tween.tween_property(package, "modulate:a", 0.0, 0.1)
	
	await get_tree().process_frame
	_show_toast()
	

func _show_toast():
	var Toasttween = create_tween()
	
	$toastNotification/Control.position = off_screen_pos
	
	Toasttween.tween_property($toastNotification/Control, "position", on_screen_pos, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Toasttween.tween_interval(4.0)
	Toasttween.tween_property($toastNotification/Control, "position", off_screen_pos, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
