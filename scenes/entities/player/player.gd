extends CharacterBody3D

@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3
@export var lock_on_speed := 5.0

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
# source: https://youtu.be/IOe1aGY6hXA?feature=shared

@export var base_speed := 4.0
@export var run_speed := 6.0
@export var defend_speed := 2.0
@export var backwards_speed := 4.0
@export var dodge_speed := 60.0

@export var min_stamina := 20.0
@export var dodge_stamina := 10.0
var speed_modifier := 1.0
var stamina_drain_rate := 40
var time_elapsed := 0.0
const UPDATE_INTERVAL = 0.02

@onready var camera = $CameraController/Camera3D
@onready var ui = $UI
@onready var pause_menu = $PauseMenu
@onready var skin = $skin

@onready var healEffect = $HealEffect
@onready var dodge_timer = $Timers/DodgeTimer

var movement_input := Vector2.ZERO
var last_movement_input := Vector2(0,1)
var defend := false:
	set(value):
		if not defend and value:
			skin.defend(true)
		if defend and not value:
			skin.defend(false)
		defend = value
var weapon_active := true:
	set(value):
		weapon_active = value
		#if weapon_active:
			#ui.get_node("Spells").hide()
		#else:
			#ui.get_node("Spells").show()
var health := 100.0:
	set(value):
		ui.update_health(health, value)
		health = clamp(value, 0.0, 100.0)
		if health <= 0.0:
			skin.kill()
			ui.kill()
			is_dead = true
			call_deferred("_kill_player")
#var energy := 100:
	#set(value):
		#energy = min(100, value)
		#ui.update_energy(energy)
var stamina := 100.0:
	set(value):
		ui.update_stamina(stamina, value)
		#if stamina == 100 and value < 100:
			#ui.change_stamina_alpha(1.0)
		#if value == 100:
			#ui.change_stamina_alpha(0.0)
		stamina = clamp(value, 0.0, 100.0)
var is_dead := false
var health_potions := 3:
	set(value):
		health_potions = clamp(value, 0, 99)
		ui.update_health_potion(value)

var locked_target: Node3D = null
@export var lock_on_range: float = 15.0
@export var lock_on_angle: float = 90.0 # degrees

var target_angle:float

const VECTOR2_UP_LEFT = Vector2(-1,-1)
const VECTOR2_UP_RIGHT = Vector2(1,-1)
const VECTOR2_DOWN_LEFT = Vector2(-1,1)
const VECTOR2_DOWN_RIGHT = Vector2(1,1)

var is_paused := false

func _ready() -> void:
	Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	Global.target_locked.connect(_on_target_locked)


func _physics_process(delta: float) -> void:
	pause_logic()
	if not is_dead:
		move_logic(delta)
		jump_logic(delta)
		ability_logic()
		move_and_slide()
		target_lock_logic(delta)


func move_logic(delta:float) -> void:
	var dir_input =  Input.get_vector("left", "right", "forward", "backward")
	var dir = round(dir_input)
	movement_input = dir_input.rotated(-camera.global_rotation.y)
	var vel_2d = Vector2(velocity.x, velocity.z)
	var is_running = Input.is_action_pressed("run") && stamina > 0.0
	if movement_input !=  Vector2.ZERO and not dodge_timer.time_left:
		var speed = run_speed if is_running else base_speed
		speed = defend_speed if defend else speed
		speed = backwards_speed if (dir == Vector2.DOWN or dir == VECTOR2_DOWN_LEFT or dir == VECTOR2_DOWN_RIGHT) and locked_target else speed
		
		vel_2d += movement_input * speed #* 8.0 # * delta -- removing acceleration
		vel_2d = vel_2d.limit_length(speed) * speed_modifier
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		
		if is_running and not locked_target:
			skin.set_move_state('Running')
		elif is_running and locked_target and dir == Vector2.UP:
			skin.set_move_state('Running')
		else:
			if locked_target:
				if dir == Vector2.DOWN or dir == VECTOR2_DOWN_LEFT or dir == VECTOR2_DOWN_RIGHT:
					skin.set_move_state('Walking_Backwards')
				elif dir == Vector2.LEFT or dir == VECTOR2_UP_LEFT:
					skin.set_move_state('Running_Strafe_Left')
				elif dir == Vector2.RIGHT or dir == VECTOR2_UP_RIGHT:
					skin.set_move_state('Running_Strafe_Right')
				else:
					skin.set_move_state('Walking')
			else:
				skin.set_move_state('Walking')
		target_angle = -movement_input.angle() + PI/2
	else:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, base_speed * 4.0 )#* delta)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		skin.set_move_state('Idle')
	if skin.rotation.y != target_angle:
		skin.rotation.y = rotate_toward(skin.rotation.y, target_angle, 10 * delta)
	if movement_input:
		last_movement_input = movement_input.normalized()
	
	var is_currently_running = is_on_floor() and is_running and movement_input != Vector2.ZERO
	if is_currently_running && time_elapsed >= UPDATE_INTERVAL:
		time_elapsed -= UPDATE_INTERVAL
		@warning_ignore("narrowing_conversion")
		stamina -= stamina_drain_rate * delta
		$Timers/StaminaRecoveryTimer.paused = true
	else:
		time_elapsed += delta
		time_elapsed = clamp(time_elapsed, 0.0, UPDATE_INTERVAL)
	if not is_currently_running:
		$Timers/StaminaRecoveryTimer.paused = false
	#run_particles.emitting = is_currently_running
	#if is_on_floor() and movement_input:
		#if not $Sounds/StepSound.playing:
			#$Sounds/StepSound.playing = true
	#else:
		#$Sounds/StepSound.playing = false
		
	if Input.is_action_just_pressed("dodge") and stamina > min_stamina and not dodge_timer.time_left:
		stamina -= dodge_stamina
		skin.dodge()
		var tween = create_tween()
		tween.set_parallel()
		if locked_target:
			if dir == Vector2.ZERO:
				tween.tween_property(self, "velocity", -skin.transform.basis.z * dodge_speed, 0.4)
			if dir == Vector2.LEFT:
				tween.tween_property(self, "velocity", skin.transform.basis.x * dodge_speed, 0.4)
			if dir == Vector2.RIGHT:
				tween.tween_property(self, "velocity", -skin.transform.basis.x * dodge_speed, 0.4)
			if dir == Vector2.UP:
				tween.tween_property(self, "velocity", skin.transform.basis.z * dodge_speed, 0.4)
			if dir == Vector2.DOWN:
				tween.tween_property(self, "velocity", -skin.transform.basis.z * dodge_speed, 0.4)
			if dir == VECTOR2_UP_LEFT:
				tween.tween_property(self, "velocity", skin.transform.basis.x * dodge_speed, 0.4)
				tween.tween_property(self, "velocity", skin.transform.basis.z * dodge_speed, 0.4)
			if dir == VECTOR2_UP_LEFT:
				tween.tween_property(self, "velocity", -skin.transform.basis.x * dodge_speed, 0.4)
				tween.tween_property(self, "velocity", skin.transform.basis.z * dodge_speed, 0.4)
			if dir == VECTOR2_DOWN_LEFT:
				tween.tween_property(self, "velocity", skin.transform.basis.x * dodge_speed, 0.4)
				tween.tween_property(self, "velocity", -skin.transform.basis.z * dodge_speed, 0.4)
			if dir == VECTOR2_DOWN_RIGHT:
				tween.tween_property(self, "velocity", -skin.transform.basis.x * dodge_speed, 0.4)
				tween.tween_property(self, "velocity", -skin.transform.basis.z * dodge_speed, 0.4)
		else:
			tween.tween_property(self, "velocity", skin.transform.basis.z * dodge_speed, 0.4)
		dodge_timer.start()
		#velocity = skin.transform.basis.z * dodge_speed

func jump_logic(delta:float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump") and stamina >= min_stamina:
			velocity.y = -jump_velocity
			do_squash_and_stretch(1.2, 0.15)
			stamina -= 10.0
	else:
		skin.set_move_state('Jump')
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta


func ability_logic() -> void:
	#actual attack
	if Input.is_action_just_pressed("ability") and stamina >= min_stamina:
		#if weapon_active:
		stamina = skin.attack(stamina)
		#else:
			#if energy >= 20:
				#skin.cast_spell()
				#stop_movement(0.3, 0.8)
				#energy -= 20
	
	#defend
	defend = Input.is_action_pressed("block") and stamina > min_stamina
	
	#switch weapon/magic
	#if Input.is_action_just_pressed("switch weapon") and not skin.attacking:
		#weapon_active = not weapon_active
		#skin.switch_weapon(weapon_active)
		#do_squash_and_stretch(1.2, 0.15)
		
	#if Input.is_action_just_pressed("switch spell") and not skin.attacking and not weapon_active:
		#current_spell = spells[spells.keys()[(int(current_spell) + 1) % len(spells)]]
		#ui.update_spell(spells, current_spell)
		
	if Input.is_action_just_pressed("heal") and health_potions > 0 and not $Timers/HealTimer.time_left:
		health += 50
		health_potions -= 1
		healEffect.get_node("GPUParticles3D").emitting = true
		$Timers/HealTimer.start()



func stop_movement(start_duration:float, end_duration:float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)


func hit(value:float) -> void:
	if not $Timers/InvulTimer.time_left:
		if defend and stamina >= min_stamina:
			stamina -= min_stamina
			stop_movement(0.3,0.3)
			$Timers/InvulTimer.start()
		else:
			skin.hit()
			stop_movement(0.3,0.3)
			health -= value
			$Timers/InvulTimer.start()


func do_squash_and_stretch(value: float, duration: float = 0.1) -> void:
	var tween = create_tween()
	tween.tween_property(skin, "squash_and_stretch", value, duration)
	tween.tween_property(skin, "squash_and_stretch", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)


func _on_stamina_recovery_timer_timeout() -> void:
	if not defend:
		stamina += 1.2
	else:
		stamina += 0.25


func pause_logic() -> void:
	if Input.is_action_just_pressed("pause"):
		pause_menu.pause_game()


func target_lock_logic(delta:float) -> void:
	if Input.is_action_just_pressed("target_lock"):
		toggle_lock_on()
	if Input.is_action_just_pressed("switch_target"):
		switch_target()
	rotate_towards_target(delta)


func toggle_lock_on():
	if locked_target:
		var target = locked_target
		Global.target_locked.emit(target, false)
	else:
		locked_target = find_nearest_target()
		if locked_target:
			var target = locked_target
			Global.target_locked.emit(target, true)


func switch_target():
	if locked_target:
		var new_target = find_next_target()
		if new_target:
			var target = locked_target
			Global.target_locked.emit(target, false)
			locked_target = new_target
			Global.target_locked.emit(new_target, true)


func find_nearest_target() -> Node3D:
	var nearest: Node3D = null
	var min_distance = lock_on_range
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		var to_enemy = enemy.global_position - global_position
		var distance = to_enemy.length()
		if distance <= lock_on_range && distance < min_distance:
			min_distance = distance
			nearest = enemy
	return nearest


func find_next_target():
	var enemies_in_range: Array = []
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		var to_enemy = enemy.global_position - global_position
		var distance = to_enemy.length()
		if distance <= lock_on_range:
			enemies_in_range.append({"enemy": enemy})
	if enemies_in_range.is_empty():
		return null
	# Find index of current locked_target
	var idx = -1
	for i in enemies_in_range.size():
		if enemies_in_range[i]["enemy"] == locked_target:
			idx = i
			break
	# Get next target
	if idx == -1:
		# If no target is locked yet, pick the first one
		return enemies_in_range[0]["enemy"]
	else:
		# Cycle to next, wrap around
		var next_idx = (idx + 1) % enemies_in_range.size()
		return enemies_in_range[next_idx]["enemy"]


func rotate_towards_target(_delta: float) -> void:
	if locked_target:
		# Look at the marker instead of raw target position
		var target_pos = locked_target.global_position
		var to_target: Vector3 = (target_pos - global_position).normalized()
		var target_basis: Basis = Basis.looking_at(to_target, Vector3.UP)
		target_basis = target_basis.rotated(Vector3.UP, -PI)
		skin.basis = target_basis
		#skin.basis = skin.basis.slerp(target_basis, lock_on_speed * delta)


func _on_target_locked(enemy_node: Node3D, is_locked: bool) -> void:
	if not is_locked and enemy_node and locked_target and enemy_node.name == locked_target.name:
		locked_target = null


func pickup_health_potion(value:int) -> void:
	health_potions += value


func _kill_player() -> void:
	$CollisionShape3D.disabled = true
