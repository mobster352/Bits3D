extends Control

var can_pause := true

func pause(value:bool) -> void:
	can_pause = not value
	if value:
		show()
		get_tree().paused = true
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE
	else:
		hide()
		get_tree().paused = false
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and can_pause:
		pause(false)


func _on_pause_timer_timeout() -> void:
	can_pause = true


func _on_respawn_button_pressed() -> void:
	get_tree().reload_current_scene()
