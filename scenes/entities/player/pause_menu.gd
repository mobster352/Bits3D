extends Control

@export var menu:Control
@export var options:Control

var can_pause := true
var is_paused := false

func pause_game():
	is_paused = not is_paused
	pause()

func pause() -> void:
	if is_paused:
		show()
		get_tree().paused = true
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE
	else:
		hide()
		get_tree().paused = false
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED


#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("pause") and is_paused and can_pause:
		#can_pause = false
		#$Timers/PauseTimer.start()
		#pause_game()


#func _on_pause_timer_timeout() -> void:
	#can_pause = true


func _on_respawn_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", "res://scenes/levels/main_menu.tscn")


func _on_options_button_pressed() -> void:
	menu.hide()
	options.sibling = menu
	options.show()


func _on_resume_button_pressed() -> void:
	is_paused = false
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED
