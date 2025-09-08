extends Node3D

@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var attack_state_machine = $AnimationTree.get("parameters/AttackStateMachine/playback")
@onready var extra_animation = $AnimationTree.get_tree_root().get_node('ExtraAnimation')

var attacking := false
var is_hit := false
var squash_and_stretch := 1.0:
	set(value):
		squash_and_stretch = value
		var negative = 1.0 + (1.0 - squash_and_stretch)
		scale = Vector3(negative,squash_and_stretch,negative)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_move_state(state_name:String) -> void:
	move_state_machine.travel(state_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func attack(stamina:int) -> int:
	if not attacking and not is_hit:
		attack_state_machine.travel('1H_Diagonal')
		$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		#get_parent().get_node("Sounds/SwordSound").play()
		return stamina - 20
	return stamina


func attack_toggle(value:bool) -> void:
	attacking = value

func hit_toggle(value:bool) -> void:
	is_hit = value

func defend(forward:bool) -> void:
	var tween = create_tween()
	tween.tween_method(_defend_change, 1.0 - float(forward), float(forward), 0.25)


func _defend_change(value:float) -> void:
	$AnimationTree.set("parameters/ShieldBlend/blend_amount", value)
	
func can_damage(value:bool):
	$Rig/Skeleton3D/BoneAttachment3D/Sword1H.can_damage = value
	
func hit() -> void:
	extra_animation.animation = 'Hit_A'
	$AnimationTree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	attacking = false
	is_hit = true
	#var tween = create_tween()
	#tween.tween_method(_hit_effect, 0.0, 0.5, 0.3)
	#tween.tween_method(_hit_effect, 0.5, 0.0, 0.1)
	
func _hit_effect(value:float) -> void:
	$Rig/Skeleton3D/Godette_Body.material_overlay.set_shader_parameter('color', Color.FIREBRICK)
	$Rig/Skeleton3D/Godette_Body.material_overlay.set_shader_parameter('alpha', value)
	
func kill() -> void:
	$AnimationTree.set("parameters/DeathOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	attacking = false
