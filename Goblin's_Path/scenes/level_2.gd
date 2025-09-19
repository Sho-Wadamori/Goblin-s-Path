extends Node2D

@onready var SceneChangeAnimationParent = $SceneChangeAnimation
@onready var box = $SceneChangeAnimation/Control/ColorRect
@onready var timer_label = $YSorting/Goblin/Timer/Label
@onready var hearts = $YSorting/Goblin/Health/Control
@onready var level_intro = $YSorting/Goblin/LevelIntro/CenterContainer
@onready var bg_music = $bg_music

@onready var portalfade = $"Portal Fade"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await fade_out(1)
	
	fade_in_timer()
	fade_in_heart()
	
	portalfade.play("portal-fade")
	
	await fade_level_intro()


func _on_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://Goblin's_Path/scenes/tutorial.tscn")
	print_debug("DEBUG: Game Restarted")


func fade_out(time = 0.5) -> void:
	SceneChangeAnimationParent.show()
	box.color = Color(0, 0, 0, 1)
	var tween = create_tween()
	tween.tween_property(box, "color", Color(0, 0, 0, 0), time)
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
	
	# Fade in: 0 -> 1 sec
	tween.tween_property(level_intro, "modulate:a", 1.0, 1.0)
	
	# Wait 2 seconds (1-3s solid)
	tween.tween_interval(2.0)
	
	# Fade out: 3 -> 4 sec
	tween.tween_property(level_intro, "modulate:a", 0.0, 1.0)
	
	await tween.finished
