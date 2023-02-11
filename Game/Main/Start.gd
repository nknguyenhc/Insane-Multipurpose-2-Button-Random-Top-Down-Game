extends Node

var button2 = "button2"

func _process(delta):
	if Input.is_action_just_pressed(button2):
		get_parent().start_game()
