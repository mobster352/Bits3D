extends Node3D

@export var min_limit_x: float
@export var max_limit_x: float
@export var horizontal_acceleration := 2.0
@export var vertical_acceleration := 1.0
@export var mouse_acceleration := 0.005
@export var lock_on_speed := 5.0

var has_target := false
var target_marker: Node3D

func _ready() -> void:
	Global.target_locked.connect(_on_target_locked)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not has_target:
		rotate_from_vector(event.relative * mouse_acceleration)

func _process(delta: float) -> void:
	if has_target and target_marker:
		rotate_towards_target(delta)

func rotate_from_vector(v: Vector2) -> void:
	if v.length() == 0:
		return
	rotation.y -= v.x
	rotation.x = clamp(rotation.x - v.y, min_limit_x, max_limit_x)

func rotate_towards_target(delta: float) -> void:
	var marker_pos = target_marker.global_position
	var to_target: Vector3 = (marker_pos - global_position).normalized()
	var target_basis: Basis = Basis.looking_at(to_target, Vector3.UP)
	
	basis = basis.slerp(target_basis, lock_on_speed * delta)

func _on_target_locked(enemy_node: Node3D, is_locked: bool) -> void:
	has_target = is_locked
	if is_locked:
		if enemy_node.has_node("LockOnPoint"):
			target_marker = enemy_node.get_node("LockOnPoint") as Node3D
		else:
			target_marker = enemy_node
	else:
		target_marker = null
