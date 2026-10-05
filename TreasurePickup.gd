extends Area2D

@export var coin_value := 15

func _ready():
	_add_shine()
	monitoring = false
	connect("area_entered", Callable(self, "_on_area_entered"))
	await get_tree().create_timer(0.5).timeout
	monitoring = true

func _on_area_entered(area):
	if not area.is_in_group("player_hurtbox"):
		return
	var player = area.get_parent()
	if player.is_in_group("player") and player.has_method("add_money"):
		player.add_money(coin_value)
		queue_free()

func _add_shine():
	var sheet = load("res://Assets/Treasure+/Shine7_sheet.png")
	if sheet == null:
		return
	var frames := SpriteFrames.new()
	frames.set_animation_speed("default", 10)
	for f in 8:
		var at := AtlasTexture.new()
		at.atlas = sheet
		at.region = Rect2(f * 16, 0, 16, 16)
		frames.add_frame("default", at)
	var s := AnimatedSprite2D.new()
	s.sprite_frames = frames
	s.scale = Vector2(2, 2)
	add_child(s)
	s.play("default")
