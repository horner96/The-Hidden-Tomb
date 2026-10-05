extends Control

func _ready():
	$Center/ContinueButton.pressed.connect(func(): get_tree().change_scene_to_file("res://main.tscn"))
	$Center/ContinueButton.grab_focus()
