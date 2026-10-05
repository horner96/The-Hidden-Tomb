extends Area2D

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	if not area.is_in_group("player_hurtbox"):
		return

	var player = area.get_parent()

	if player.has_method("heal"):
		player.heal(player.max_hp)
		queue_free()
