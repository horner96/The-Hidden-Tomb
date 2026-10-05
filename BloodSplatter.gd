extends Node2D

const PIXEL_SIZE := 3.0
const GRAVITY := 520.0

var _positions: Array[Vector2] = []
var _velocities: Array[Vector2] = []
var _colors: Array[Color] = []
var _age := 0.0
var _lifetime := 0.45

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in 12:
		_positions.append(Vector2.ZERO)
		var angle := rng.randf_range(PI * 1.1, PI * 1.9)
		var speed := rng.randf_range(70.0, 190.0)
		_velocities.append(Vector2.RIGHT.rotated(angle) * speed)
		_colors.append(Color(
			rng.randf_range(0.65, 1.0),
			rng.randf_range(0.0, 0.08),
			rng.randf_range(0.0, 0.05),
			1.0
		))

func _process(delta: float) -> void:
	_age += delta
	for i in _positions.size():
		var velocity := _velocities[i]
		velocity.y += GRAVITY * delta
		_velocities[i] = velocity
		_positions[i] += velocity * delta
	queue_redraw()
	if _age >= _lifetime:
		queue_free()

func _draw() -> void:
	var fade := 1.0 - (_age / _lifetime)
	for i in _positions.size():
		var color := _colors[i]
		color.a = fade
		draw_rect(Rect2(_positions[i], Vector2(PIXEL_SIZE, PIXEL_SIZE)), color)
