extends Area2D

var triggered := false

func _ready():
	monitoring = false
	connect("area_entered", Callable(self, "_on_area_entered"))
	await get_tree().create_timer(0.5).timeout
	monitoring = true

func _on_area_entered(area):
	if triggered or not area.is_in_group("player_hurtbox"):
		return
	var player = area.get_parent()
	if player.is_in_group("player"):
		triggered = true
		var screen = preload("res://VictoryScreen.tscn").instantiate()
		screen.money = player.money
		get_tree().current_scene.add_child(screen)
		get_tree().paused = true
