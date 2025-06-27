extends Node2D

@onready var enemy_prefab = preload("res://Goblin's_Path/prefabs/enemy(previous).tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Goblin's_Path/scenes/tutorial.tscn")
	print("DEBUG: Game Restarted")
