extends Area2D
class_name enemy

@export var speed = 2
@onready var explosion_prefab = preload("res://Goblin's_Path/prefabs/explosion(previous).tscn")
@onready var laser_prefab = preload("res://Goblin's_Path/prefabs/enemy_laser(previous).tscn")
signal enemy_killed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position.x -= speed
	


func _on_area_entered(area):
	if area is laser:
		var explosion = explosion_prefab.instantiate()
		explosion.position = position
		get_parent().add_child(explosion)
		queue_free()
		area.queue_free()
		enemy_killed.emit()


func _on_shoot_timer_timeout():
	var new_laser = laser_prefab.instantiate()
	new_laser.position = position
	get_parent().add_child(new_laser)
