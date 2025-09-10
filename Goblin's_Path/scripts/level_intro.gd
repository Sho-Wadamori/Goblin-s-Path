extends CanvasLayer

@onready var Level_Label = $CenterContainer/HBoxContainer/LevelName

var level_names := {
	"tutorial": "[center]Inner Woods",
	"Level 1": "[center]Forest Edge",
	"Level 2": "[center]The Dungeon"
}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_level_label()


func update_level_label() -> void:
	var current_scene := get_tree().current_scene
	if current_scene:
		var path := current_scene.scene_file_path
		var scene_name := path.get_file().get_basename()  # "tutorial" from "tutorial.tscn"

		if scene_name in level_names:
			Level_Label.bbcode_text = level_names[scene_name]
		else:
			Level_Label.bbcode_text = "[center]??? Lvl"
