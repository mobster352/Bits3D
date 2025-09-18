extends LineEdit

enum VAR_TYPE {
	FLOAT,
	INT,
	TEXT
}

@export var type:VAR_TYPE
@export var h_slider:HSlider

func _on_text_changed(new_text: String) -> void:
	if type == VAR_TYPE.TEXT:
		var regex = RegEx.new()
		regex.compile("[^a-zA-Z0-9]")
		var cleaned_text = regex.sub(new_text, "", true)
		text = cleaned_text.to_upper()
	elif type == VAR_TYPE.INT:
		text = str(clamp(new_text.to_int(), 0, 100))
	elif type == VAR_TYPE.FLOAT:
		var new_float = clamp(new_text.to_float(), 0.0, 0.01)
		text = str(new_float)
		h_slider.value = new_float
	caret_column = new_text.length()
