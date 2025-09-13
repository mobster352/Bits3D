extends Node3D

@export var item:Global.ITEMS

@onready var pickupUI = $PickupUI
@onready var itemPickedUpUI = $ItemPickedUpUI
@onready var itemPickedUpLabel = $ItemPickedUpUI/MarginContainer/Label
@onready var pickupTimer = $Timers/PickupTimer
@onready var auraParticles = $AuraParticles
@onready var player = get_tree().get_first_node_in_group('Player')

var is_player_in_range := false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("use") and pickupTimer.time_left:
		queue_free()
		
	if Input.is_action_just_pressed("use") and is_player_in_range and not pickupTimer.time_left:
		pickupUI.hide()
		if item == Global.ITEMS.HEALTH_POTION:
			player.pickup_health_potion(1)
			itemPickedUpLabel.text = "Health Potion picked up"
		itemPickedUpUI.show()
		pickupTimer.start()
		auraParticles.emitting = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group('Player'):
		pickupUI.show()
		is_player_in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group('Player'):
		pickupUI.hide()
		is_player_in_range = false


func _on_pickup_timer_timeout() -> void:
	queue_free()
