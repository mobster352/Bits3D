class_name Enemy
extends CharacterBody3D

@warning_ignore("unused_signal")
signal cast_spell(type:String, pos:Vector3, direction:Vector2, size:float)

@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var attack_animation = $AnimationTree.get_tree_root().get_node('AttackAnimation')
@onready var death_state_machine = $AnimationTree.get("parameters/DeathStateMachine/playback")
@onready var player = get_tree().get_first_node_in_group('Player')
@onready var skin = get_node('skin')
@onready var health_bar = $HealthBar/SubViewport/TextureProgressBar

@export var walk_speed := 2.0
@export var speed = walk_speed
var speed_modifier := 1.0
@export var notice_radius := 30.0
@export var attack_radius := 3.0
var health := 100:
	set(value):
		update_health(health, value)
		health = value
		if health <= 0:
			is_dead = true
			$AnimationTree.set("parameters/DeathOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			$CollisionShape3D.disabled = true
			health_bar.hide()
var is_dead := false

var rng = RandomNumberGenerator.new()
var squash_and_stretch := 1.0:
	set(value):
		squash_and_stretch = value
		var negative = 1.0 + (1.0 - squash_and_stretch)
		skin.scale = Vector3(negative,squash_and_stretch,negative)

func move_to_player(delta:float):
	if position.distance_to(player.position) < notice_radius && not player.is_dead && not is_dead:
		var target_dir = (player.position - position).normalized()
		var target_vec2 = Vector2(target_dir.x, target_dir.z)
		var target_angle = -target_vec2.angle() + PI/2
		rotation.y = rotate_toward(rotation.y, target_angle, delta * 6.0)
		if position.distance_to(player.position) > attack_radius:
			velocity = Vector3(target_vec2.x, 0, target_vec2.y) * speed * speed_modifier
			move_state_machine.travel('Walk')
		else:
			velocity = Vector3.ZERO
			move_state_machine.travel('Idle')
			
		if not is_on_floor():
			velocity.y -= 2
		else:
			velocity.y = 0
		move_and_slide()
	else:
		velocity = Vector3.ZERO
		move_state_machine.travel('Idle')

func stop_movement(start_duration:float, end_duration:float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)

func hit() -> void:
	if not $Timers/InvulTimer.time_left and not is_dead:
		do_squash_and_stretch(1.2, 0.15)
		$Timers/InvulTimer.start()
		health -= 20

func do_squash_and_stretch(value: float, duration: float = 0.1) -> void:
	var tween = create_tween()
	tween.tween_property(self, "squash_and_stretch", value, duration)
	tween.tween_property(self, "squash_and_stretch", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)
	
	
func update_health(current:int, target:int) -> void:
	var tween = create_tween()
	tween.tween_method(_change_health, current, target, 0.25)


func _change_health(value:int) -> void:
	health_bar.value = value
