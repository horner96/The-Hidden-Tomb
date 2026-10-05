@tool
extends Area2D

@export var spike_count := 4:
	set(v):
		spike_count = max(1, v)
		_refresh()
@export var spike_width := 16.0:
	set(v):
		spike_width = v
		_refresh()
@export var spike_height := 14.0:
	set(v):
		spike_height = v
		_refresh()
@export var damage := 10
@export var hit_interval := 0.5

var _cooldown := 0.0
var _shines: Node2D
var _frames: SpriteFrames

func _ready():
	_refresh()

func _refresh():
	if not is_inside_tree():
		return
	var w := spike_count * spike_width
	var top := spike_height * 0.7
	var area_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if area_shape:
		var rect := RectangleShape2D.new()
		rect.size = Vector2(w, top + 2.0)
		area_shape.shape = rect
		area_shape.position = Vector2(w * 0.5, -(top + 2.0) * 0.5)
	var solid_shape := get_node_or_null("Solid/CollisionShape2D") as CollisionShape2D
	if solid_shape:
		var rect2 := RectangleShape2D.new()
		rect2.size = Vector2(w, top)
		solid_shape.shape = rect2
		solid_shape.position = Vector2(w * 0.5, -top * 0.5)
	_rebuild_shines()
	queue_redraw()

func _draw():
	for i in spike_count:
		var x := i * spike_width
		draw_colored_polygon(
			PackedVector2Array([Vector2(x, 0), Vector2(x + spike_width * 0.5, -spike_height), Vector2(x + spike_width, 0)]),
			Color(0.75, 0.72, 0.65))
		draw_polyline(
			PackedVector2Array([Vector2(x, 0), Vector2(x + spike_width * 0.5, -spike_height), Vector2(x + spike_width, 0)]),
			Color(0.25, 0.2, 0.15), 1.0)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(damage)
			_cooldown = hit_interval
			return

func _rebuild_shines():
	if _shines == null:
		_shines = Node2D.new()
		add_child(_shines)
	for c in _shines.get_children():
		c.queue_free()
	if _frames == null:
		var sheet = load("res://Assets/Treasure+/Shine1_sheet.png")
		if sheet == null:
			return
		_frames = SpriteFrames.new()
		_frames.set_animation_speed("default", 10)
		for f in 7:
			var at := AtlasTexture.new()
			at.atlas = sheet
			at.region = Rect2(f * 16, 0, 16, 16)
			_frames.add_frame("default", at)
	for i in spike_count:
		var s := AnimatedSprite2D.new()
		s.sprite_frames = _frames
		s.position = Vector2(i * spike_width + spike_width * 0.5, -spike_height * 0.8)
		s.scale = Vector2(1, 0.5)
		s.frame = randi() % 7
		s.play("default")
		_shines.add_child(s)

