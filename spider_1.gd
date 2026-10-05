extends AnimatedSprite2D

@export var move_distance := 15.0
@export var move_speed := 20.0

var start_x: float
var direction := 1

func _ready() -> void:
	move_distance = randf_range(8.0, 18.0)
	move_speed = randf_range(10.0, 22.0)
	direction = [-1, 1].pick_random()

	frame = randi_range(0, sprite_frames.get_frame_count("default") - 1)

	start_x = position.x
	play("default")

func _process(delta: float) -> void:
	position.x += move_speed * direction * delta

	if position.x >= start_x + move_distance:
		direction = -1
		flip_h = true

	elif position.x <= start_x - move_distance:
		direction = 1
		flip_h = false
