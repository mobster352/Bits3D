extends Control

@export var sibling:Control
var waiting_for_input: String = ""

func _ready():
	load_keybindings()


func _on_back_button_pressed() -> void:
	hide()
	sibling.show()


func save_keybinding(action_name: String, event: InputEventKey) -> void:
	var cfg := ConfigFile.new()
	var path = "user://settings.cfg"

	cfg.load(path)

	cfg.set_value("keybindings", action_name + "_physical", event.physical_keycode)
	cfg.set_value("keybindings", action_name + "_logical", event.keycode)
	
	update_action_input_field(action_name, OS.get_keycode_string(event.physical_keycode))
	#Global.update_keybinding.emit(action_name, event.physical_keycode)

	cfg.save(path)
	#print("Saved binding for %s" % action_name)


func load_keybindings() -> void:
	var cfg := ConfigFile.new()
	var path = "user://settings.cfg"
	if cfg.load(path) != OK:
		return

	for action_name in InputMap.get_actions():
		if cfg.has_section_key("keybindings", action_name + "_physical"):
			var ev := InputEventKey.new()
			ev.physical_keycode = cfg.get_value("keybindings", action_name + "_physical")
			ev.keycode = cfg.get_value("keybindings", action_name + "_logical")
			ev.pressed = false
			
			update_action_input_field(action_name,  OS.get_keycode_string(cfg.get_value("keybindings", action_name + "_physical")))

			InputMap.action_erase_events(action_name)
			InputMap.action_add_event(action_name, ev)
			#print("Loaded binding for %s" % action_name)


func char_to_key_event(c: String) -> InputEventKey:
	var ev := InputEventKey.new()
	var code = c.to_upper().unicode_at(0)
	@warning_ignore("int_as_enum_without_cast")
	ev.physical_keycode = code
	@warning_ignore("int_as_enum_without_cast")
	ev.keycode = code
	ev.pressed = false
	return ev
	
	
func remap_action(action_name: String, event: InputEventKey) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	save_keybinding(action_name, event)
	#print("Remapped %s to key: %s" % [action_name, OS.get_keycode_string(event.unicode)])


func _input(event: InputEvent) -> void:
	if waiting_for_input != "":
		if event is InputEventKey and event.pressed and not event.echo:
			remap_action(waiting_for_input, event)
			waiting_for_input = ""


#func _on_heal_input_text_changed(new_text: String) -> void:
	#if new_text:
		#var ev = char_to_key_event(new_text)
		#remap_action("heal", ev)


func update_action_input_field(action_name:String, value:String) -> void:
	if action_name == "heal":
		$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/Heal/HealButton.text = value
		$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/Heal/Tooltip.hide()
		Global.update_keybinding.emit(action_name,value)
	elif action_name == "dodge":
		$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/Dodge/DodgeButton.text = value
		$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/Dodge/Tooltip.hide()
	elif action_name == "target_lock":
		$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/TargetLock/TargetLockButton.text = value
		$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/TargetLock/Tooltip.hide()
	elif action_name == "switch_target":
		$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/SwitchTarget/SwitchTargetButton.text = value
		$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/SwitchTarget/Tooltip.hide()
	elif action_name == "jump":
		$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/Jump/JumpButton.text = value
		$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/Jump/Tooltip.hide()



func _on_h_slider_value_changed(value: float) -> void:
	Global.save_keybinding("mouse_sensitivity", value)


func _on_heal_button_pressed() -> void:
	waiting_for_input = "heal"
	$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/Heal/Tooltip.show()


func _on_dodge_button_pressed() -> void:
	waiting_for_input = "dodge"
	$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/Dodge/Tooltip.show()


func _on_target_lock_button_pressed() -> void:
	waiting_for_input = "target_lock"
	$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/TargetLock/Tooltip.show()


func _on_switch_target_button_pressed() -> void:
	waiting_for_input = "switch_target"
	$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/SwitchTarget/Tooltip.show()


func _on_jump_button_pressed() -> void:
	waiting_for_input = "jump"
	$PanelContainer/ScrollContainer/MarginContainer/VBoxContainer/Jump/Tooltip.show()
