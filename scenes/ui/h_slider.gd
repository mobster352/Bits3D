extends HSlider

@export var line_edit:LineEdit

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


func _ready() -> void:
	value = Global.load_keybinding("mouse_sensitivity")
	line_edit.text = str(mouse_sens_dict.find_key(str(value)))

@warning_ignore("shadowed_variable_base_class")
func _on_value_changed(value: float) -> void:
	line_edit.text = str(mouse_sens_dict.find_key(str(value)))
