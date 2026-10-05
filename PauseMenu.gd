extends CanvasLayer

func _ready():
	visible = false
	$Root/Center/ResumeButton.pressed.connect(_resume)
	$Root/Center/TitleButton.pressed.connect(_to_title)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_resume()
		else:
			visible = true
			get_tree().paused = true
			$Root/Center/ResumeButton.grab_focus()
		get_viewport().set_input_as_handled()

func _resume():
	visible = false
	get_tree().paused = false

func _to_title():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://TitleScreen.tscn")
