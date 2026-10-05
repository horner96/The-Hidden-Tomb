extends Control

func _ready():
	$Center/TitleButton.pressed.connect(func(): get_tree().change_scene_to_file("res://TitleScreen.tscn"))
	$Center/TitleButton.grab_focus()
