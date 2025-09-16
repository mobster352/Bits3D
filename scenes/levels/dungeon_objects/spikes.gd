extends MeshInstance3D

@export var speed := 0.1
@export var wait_time := 3.0

@onready var activate_timer := $Timers/ActivateTimer
@onready var start_position := position.y
var is_active := false


func _ready() -> void:
	activate_timer.wait_time = wait_time


func _on_activate_timer_timeout() -> void:
	var tween = create_tween()
	if is_active:
		tween.tween_method(_move_spikes, -1.2, start_position, speed)
		is_active = false
	else:
		tween.tween_method(_move_spikes, start_position, -1.2, speed)
		is_active = true


func _move_spikes(value:float) -> void:
	position.y = value


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if 'hit' in body:
			body.hit()
