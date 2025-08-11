extends Node2D

@onready var SceneChangeAnimation = $SceneChangeAnimation/AnimationPlayer

@onready var portalfade = $"Portal Fade"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneChangeAnimation.get_parent().get_node("ColorRect").color.a = 255
	SceneChangeAnimation.play("fade_out")
	#await get_tree().create_timer(1).timeout
	# Fade out the portal after 1 second
	portalfade.play("portal-fade")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://Goblin's_Path/scenes/tutorial.tscn")
	print("DEBUG: Game Restarted")
