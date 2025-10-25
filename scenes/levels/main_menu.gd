extends Control

@export var menu:Control
@export var options:Control


func _on_start_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/levels/level1.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_options_button_pressed() -> void:
	menu.hide()
	options.sibling = menu
	options.show()
