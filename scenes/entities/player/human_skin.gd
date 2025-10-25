extends Node3D

@onready var move_state_machine = $"../AnimationTree".get("parameters/MoveStateMachine/playback")
@onready var attack_state_machine = $"../AnimationTree".get("parameters/AttackStateMachine/playback")

var squash_and_stretch := 1.0:
	set(value):
		squash_and_stretch = value
		var negative = 1.0 + (1.0 - squash_and_stretch)
		scale = Vector3(negative,squash_and_stretch,negative)
		
var attacking := false
var is_hit := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_move_state(state_name:String) -> void:
	move_state_machine.travel(state_name)

func attack(stamina:float) -> float:
	if not attacking and not is_hit:
		attack_state_machine.travel('sword_attack1')
		$"../AnimationTree".set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		$"../Timers/AttackTimer".start()
		#get_parent().get_node("Sounds/SwordSound").play()
		return stamina - 20.0
	return stamina
	
func attack_toggle(value:bool) -> void:
	attacking = value
	
func can_damage(value:bool):
	$Armature/Skeleton3D/HandSlotBoneAttachment/BusterSword.can_damage = value

func hit() -> void:
	pass
	
func kill() -> void:
	pass


func _on_attack_timer_timeout() -> void:
	attack_toggle(false)
