extends ColorRect

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		unpause() if get_tree().paused else pause()

func unpause():
	if get_tree().paused:
		visible = false
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pause():
	if !get_tree().paused:
		visible = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_quit_button_pressed():
	get_tree().quit()
