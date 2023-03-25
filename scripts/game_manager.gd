extends Node

func _unhandled_input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		if !DisplayServer.window_get_mode():
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
