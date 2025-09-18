extends HSlider

@export var line_edit:LineEdit


func _ready() -> void:
	line_edit.text = str(value)

@warning_ignore("shadowed_variable_base_class")
func _on_value_changed(value: float) -> void:
	line_edit.text = str(value)
