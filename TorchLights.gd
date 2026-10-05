extends TileMapLayer

const TORCH_SOURCE_ID := 25
const TORCH_ATLAS_COORDS := Vector2i(1, 0)
const WARM_LIGHT_SCENE: PackedScene = preload("res://WarmLight.tscn")

func _ready() -> void:
	for cell in get_used_cells():
		if get_cell_source_id(cell) != TORCH_SOURCE_ID or get_cell_atlas_coords(cell) != TORCH_ATLAS_COORDS:
			continue
		var glow := WARM_LIGHT_SCENE.instantiate() as PointLight2D
		if glow == null:
			continue
		add_child(glow)
		glow.position = map_to_local(cell)
