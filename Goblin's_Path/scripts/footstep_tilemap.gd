"""
Footstep script that was surposed to change footstep sound depending on what was below
gave up
"""

extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FootstepSoundManager.tilemaps.push_back(self)
