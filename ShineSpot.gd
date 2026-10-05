extends AnimatedSprite2D

func _ready():
	if sprite_frames == null:
		var sheet = load("res://Assets/Treasure+/Shine9_sheet.png")
		if sheet == null:
			return
		var f := SpriteFrames.new()
		f.set_animation_speed("default", 10)
		for n in 7:
			var at := AtlasTexture.new()
			at.atlas = sheet
			at.region = Rect2(n * 16, 0, 16, 16)
			f.add_frame("default", at)
		sprite_frames = f
	frame = randi() % sprite_frames.get_frame_count("default")
	play("default")
