extends Control

#@onready var heart_container = $Hearts/MarginContainer/HBoxContainer
#@onready var spell_texture = $Spells/MarginContainer/TextureRect
#@onready var energy_bar = $Energy/MarginContainer/TextureProgressBar
@onready var health_bar = $Health/MarginContainer/TextureProgressBar
@onready var stamina_bar = $Stamina/MarginContainer/TextureProgressBar
#var heart_scene: PackedScene = preload("res://scenes/entities/player/heart.tscn")
#var fire_texture = preload("res://graphics/ui/fire.png")
#var heal_texture = preload("res://graphics/ui/heal.png")

#func setup(value:int) -> void:
	#for i in value:
		#var heart = heart_scene.instantiate()
		#heart_container.add_child(heart)
		#heart.change_alpha(1.0)
		#await get_tree().create_timer(0.3).timeout
#
#func update_health(value:int, direction:int) -> void:
	#for child in heart_container.get_children():
		#child.queue_free()
		#
	#if direction < 0:
		#for i in value:
			#var heart = heart_scene.instantiate()
			#heart_container.add_child(heart)
		#var extra_heart = heart_scene.instantiate()
		#heart_container.add_child(extra_heart)
		#extra_heart.change_alpha(0.0)
	#else:
		#for i in value - 1:
			#var heart = heart_scene.instantiate()
			#heart_container.add_child(heart)
		#var extra_heart = heart_scene.instantiate()
		#heart_container.add_child(extra_heart)
		#extra_heart.change_alpha(1.0)


func update_health(current:int, target:int) -> void:
	var tween = create_tween()
	tween.tween_method(_change_health, current, target, 0.25)


func _change_health(value:int) -> void:
	health_bar.value = value

#
#func update_spell(spells, current_spell) -> void:
	#if current_spell == spells.FIREBALL:
		#spell_texture.texture = fire_texture
	#if current_spell == spells.HEAL:
		#spell_texture.texture = heal_texture
#
#func update_energy(value:int) -> void:
	#energy_bar.value = value

func update_stamina(current:int, target:int) -> void:
	var tween = create_tween()
	tween.tween_method(_change_stamina, current, target, 0.25)

func _change_stamina(value:int) -> void:
	stamina_bar.value = value

func change_stamina_alpha(value:float) -> void:
	var tween = create_tween()
	tween.tween_method(_change_alpha, 1.0 - value, value, 0.25)
	
func _change_alpha(value:float) -> void:
	stamina_bar.modulate.a = value


func kill() -> void:
	$Death.show()
