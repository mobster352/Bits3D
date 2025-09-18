extends Control

@export var sibling:Control


func _on_back_button_pressed() -> void:
	hide()
	sibling.show()
