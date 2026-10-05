extends Control

const GAME_SCENE := "res://IntroScreen.tscn"

func _ready():
	$Center/Buttons/StartButton.pressed.connect(func(): get_tree().change_scene_to_file(GAME_SCENE))
	$Center/Buttons/QuitButton.pressed.connect(func(): get_tree().quit())
	$Center/Buttons/StartButton.grab_focus()


