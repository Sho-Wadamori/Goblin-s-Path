extends Node2D

@onready var SceneChangeAnimation = $SceneChangeAnimation/AnimationPlayer
@onready var LevelIntro = $YSorting/Goblin/LevelIntro/AnimationPlayer
@onready var TimerAnim = $YSorting/Goblin/Timer/AnimationPlayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneChangeAnimation.get_parent().get_node("ColorRect").color.a = 255
	SceneChangeAnimation.play("fade_out")
	$YSorting/Goblin/Timer/Label.modulate.a = 0.0
	TimerAnim.play("TimerFadeIn")
	$YSorting/Goblin/LevelIntro/CenterContainer.modulate.a = 0.0
	await get_tree().create_timer(0.5).timeout
	LevelIntro.play("LevelIntro")
	await LevelIntro.animation_finished


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://Goblin's_Path/scenes/tutorial.tscn")
	print("DEBUG: Game Restarted")
