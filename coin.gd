extends Area2D

var falling := false
const FALL_SPEED := 25.0

func _ready():
	$AnimatedSprite2D.play("coin")
	add_to_group("coins")
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area):
	var player = area.get_parent()
	if player.is_in_group("player"):
		if player.has_method("add_money"):
			player.add_money(1)
		visible = false
		$CoinSound.play()
		await $CoinSound.finished
		queue_free()

func _physics_process(delta: float):
	if not falling:
		return
	var step: float = FALL_SPEED * delta
	var q = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, step + 6), 3)
	if get_world_2d().direct_space_state.intersect_ray(q).is_empty():
		global_position.y += step
	else:
		falling = false
