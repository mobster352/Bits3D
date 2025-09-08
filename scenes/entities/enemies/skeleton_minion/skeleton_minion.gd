extends Enemy

@onready var death_timer = $Timers/DeathTimer

func _physics_process(delta: float) -> void:
	move_to_player(delta)
	if is_dead and death_timer.is_stopped():
		death_timer.start()


func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(2.0, 3.0)
	if position.distance_to(player.position) <= attack_radius * 2 and not player.is_dead and not is_dead:
		melee_attack_animation()

func melee_attack_animation() -> void:
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func can_damage(value:bool):
	$skin/Rig/Skeleton3D/BoneAttachment3D/Skeleton_Blade.can_damage = value


func _on_death_timer_timeout() -> void:
	queue_free()
