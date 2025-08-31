extends Node


var tilemaps: Array[TileMapLayer] = []

const footstep_sounds = {
	"dirt": [
		preload("res://Goblin's_Path/sprites/sound/dirt-footsteps.mp3"),
	],
	
	"grass": [
		preload("res://Goblin's_Path/sprites/sound/walking-on-pebbles-393100.mp3"),
	],
	
	"wood": [
		preload("res://Goblin's_Path/sprites/sound/explosion-42132.mp3"),
	]
}

func play_footstep(position: Vector2):
	var tile_data = []
	for tilemap in tilemaps:
		var tile_position = tilemap.local_to_map(position)
		var data = tilemap.get_cell_tile_data(tile_position)
		if data:
			tile_data.push_back(data)
	
	if tile_data.size() > 0:
		var tile_type = tile_data.back().get_custom_data("footstep_sound")
		
		if footstep_sounds.has(tile_type):
			var audio_player = AudioStreamPlayer2D.new()
			audio_player.stream = footstep_sounds[tile_type].pick_random()
			get_tree().root.add_child(audio_player)
			audio_player.global_position = position
			audio_player.play()
			await audio_player.finished
			audio_player.queue_free()
