extends CharacterBody3D

@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")
@export var pathFollow3D:PathFollow3D

func _process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 2
	else:
		velocity.y = 0
		
	move_and_slide()
	if pathFollow3D:
		if pathFollow3D.has_reached_point:
			move_state_machine.travel('Idle')
		else:
			move_state_machine.travel('Walk')
	else:
		move_state_machine.travel('Idle')
