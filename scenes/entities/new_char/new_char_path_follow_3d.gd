extends PathFollow3D

@onready var parent_path = get_parent() as Path3D
@onready var waitTimer := $WaitTimer

var target_point_index = 1
var point_offset = Vector3.ZERO
var has_reached_point = false
const DISTANCE_TO_POINT_OFFSET := 0.01

func _ready() -> void:
	if parent_path:
		point_offset = parent_path.curve.get_point_position(target_point_index)


func _process(delta: float) -> void:
	_move_on_path(delta)


func _move_on_path(delta:float) -> void:
	#progress_ratio += delta * 0.02
	if not has_reached_point:
		progress += delta * 2.0
		if position.distance_to(point_offset) <= DISTANCE_TO_POINT_OFFSET:
			#print("Reached point ", target_point_index)
			has_reached_point = true
			waitTimer.start()


func _on_wait_timer_timeout() -> void:
	if target_point_index + 1 > parent_path.curve.point_count - 1:
		target_point_index = 0
	else:
		target_point_index += 1
	point_offset = parent_path.curve.get_point_position(target_point_index)
	has_reached_point = false
