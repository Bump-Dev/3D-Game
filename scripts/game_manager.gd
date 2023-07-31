extends Node

func _unhandled_input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		if !DisplayServer.window_get_mode():
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if event.is_action_pressed("ui_focus_next"):
		get_tree().reload_current_scene()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
