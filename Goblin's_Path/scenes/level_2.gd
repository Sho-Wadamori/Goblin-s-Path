extends Node2D

@onready var SceneChangeAnimation = $SceneChangeAnimation/AnimationPlayer
@onready var LevelIntro = $YSorting/Goblin/LevelIntro/AnimationPlayer
@onready var bg_music = $"bg_music"
@onready var portalfade = $"Portal Fade"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneChangeAnimation.get_parent().get_node("ColorRect").color.a = 255
	SceneChangeAnimation.play("fade_out")
	#await get_tree().create_timer(1).timeout
	# Fade out the portal after 1 second
	portalfade.play("portal-fade")
	bg_music.play()
	
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
