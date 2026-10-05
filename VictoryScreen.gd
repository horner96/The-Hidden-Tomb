extends CanvasLayer

var money := 0

func _ready():
	$Center/Money.text = "Total Money: %d" % money
	$Center/TitleButton.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://TitleScreen.tscn"))
	$Center/TitleButton.grab_focus()
