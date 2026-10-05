extends Area2D

@export_range(0.0, 1.0) var heal_percent := 0.2

func _ready():
	monitoring = false
	connect("area_entered", Callable(self, "_on_area_entered"))
	await get_tree().create_timer(0.5).timeout
	monitoring = true

func _on_area_entered(area):
	if not area.is_in_group("player_hurtbox"):
		return
	var player = area.get_parent()
	if player.is_in_group("player") and player.has_method("heal"):
		player.heal(int(round(player.max_hp * heal_percent)))
		queue_free()
