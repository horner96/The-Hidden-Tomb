extends Node2D

@export var drop_scene: PackedScene
var broken := false

func _ready():
	add_to_group("enemies")

func take_damage(_amount):
	if broken:
		return
	broken = true
	if drop_scene:
		var drop = drop_scene.instantiate()
		drop.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", drop)
	queue_free()
