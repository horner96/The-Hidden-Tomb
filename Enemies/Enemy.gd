extends CharacterBody2D
var max_hp := 2
var hp := max_hp

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		_drop_coin()
		queue_free()
		die()
		

func _drop_coin():
	var coin_scene = preload("res://Coin.tscn")
	var coin = coin_scene.instantiate()
	coin.global_position = global_position
	coin.falling = true
	get_tree().current_scene.call_deferred("add_child", coin)
	print("coin droped at:", coin.global_position)
func die():
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
