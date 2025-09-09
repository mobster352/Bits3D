extends Enemy

@onready var death_timer = $Timers/DeathTimer
@onready var target = $Target

func _ready() -> void:
	Global.target_locked.connect(_on_target_locked)

func _physics_process(delta: float) -> void:
	move_to_player(delta)
	if is_dead and death_timer.is_stopped():
		death_timer.start()


func _on_target_locked(enemy_node:Node, is_locked:bool):
	if enemy_node and self.name == enemy_node.name:
		if is_locked:
			target.show()
		else:
			target.hide()


func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(2.0, 3.0)
	if position.distance_to(player.position) <= attack_radius * 1.5 and not player.is_dead and not is_dead:
		melee_attack_animation()

func melee_attack_animation() -> void:
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func can_damage(value:bool):
	$skin/Rig/Skeleton3D/BoneAttachment3D/Skeleton_Blade.can_damage = value


func _on_death_timer_timeout() -> void:
	queue_free()
