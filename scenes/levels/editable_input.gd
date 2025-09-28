extends LineEdit

enum VAR_TYPE {
	FLOAT,
	INT,
	TEXT
}

@export var type:VAR_TYPE
@export var h_slider:HSlider

var mouse_sens_dict := {
	"1": "0.001",
	"2": "0.002",
	"3": "0.003",
	"4": "0.004",
	"5": "0.005",
	"6": "0.006",
	"7": "0.007",
	"8": "0.008",
	"9": "0.009",
	"10": "0.01"
}

func _on_text_changed(new_text: String) -> void:
	if type == VAR_TYPE.TEXT:
		var regex = RegEx.new()
		regex.compile("[^a-zA-Z0-9]")
		var cleaned_text = regex.sub(new_text, "", true)
		text = cleaned_text.to_upper()
	elif type == VAR_TYPE.INT:
		text = str(clamp(new_text.to_int(), 0, 100))
	elif type == VAR_TYPE.FLOAT:
		var new_float = clamp(new_text.to_float(), 0.001, 0.01)
		text = str(mouse_sens_dict.find_key(str(new_float)))
		h_slider.value = new_float
	caret_column = new_text.length()
	
