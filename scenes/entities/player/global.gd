extends Node

@warning_ignore("unused_signal")
signal target_locked
@warning_ignore("unused_signal")
signal update_keybinding

enum ITEMS {
	NONE,
	HEALTH_POTION
}


func save_keybinding(key:String, value:Variant) -> void:
	var cfg := ConfigFile.new()
	var path = "user://settings.cfg"

	cfg.load(path)
	cfg.set_value("keybindings", key, value)
	cfg.save(path)
	update_keybinding.emit(key, value)


func load_keybinding(key:String) -> Variant:
	var cfg := ConfigFile.new()
	var path = "user://settings.cfg"
	if cfg.load(path) != OK:
		return

	if cfg.has_section_key("keybindings", key):
		return cfg.get_value("keybindings", key)
	return
