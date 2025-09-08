extends CharacterBody3D

@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
# source: https://youtu.be/IOe1aGY6hXA?feature=shared

@export var base_speed := 4.0
@export var run_speed := 6.0
@export var defend_speed := 2.0
var speed_modifier := 1.0
var stamina_drain_rate := 0.00001
var time_elapsed := 0.0
const UPDATE_INTERVAL = 0.02

@onready var camera = $CameraController/Camera3D
@onready var ui = $UI
@onready var pause_menu = $PauseMenu
@onready var skin = $skin

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
		health = value
		if health <= 0.0:
			skin.kill()
			ui.kill()
			is_dead = true
#var energy := 100:
	#set(value):
		#energy = min(100, value)
		##ui.update_energy(energy)
var stamina := 100:
	set(value):
		ui.update_stamina(stamina, value)
		#if stamina == 100 and value < 100:
			#ui.change_stamina_alpha(1.0)
		#if value == 100:
			#ui.change_stamina_alpha(0.0)
		stamina = clamp(value, 0, 100)
var is_dead := false

func _ready() -> void:
	Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED
	get_tree().paused = false


func _process(delta: float) -> void:
	pause_logic()
	if not is_dead:
		move_logic(delta)
		jump_logic(delta)
		ability_logic()
		move_and_slide()


func move_logic(delta:float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	var vel_2d = Vector2(velocity.x, velocity.z)
	var is_running = Input.is_action_pressed("run") && stamina > 0
	if movement_input !=  Vector2.ZERO:
		var speed = run_speed if is_running else base_speed
		speed = defend_speed if defend else speed
		
		vel_2d += movement_input * speed * 8.0 # * delta -- removing acceleration
		vel_2d = vel_2d.limit_length(speed) * speed_modifier
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		skin.set_move_state('Running')
		var target_angle = -movement_input.angle() + PI/2
		skin.rotation.y = rotate_toward(skin.rotation.y, target_angle, 10.0 * delta)
	else:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, base_speed * 4.0 )#* delta)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		skin.set_move_state('Idle')
	if movement_input:
		last_movement_input = movement_input.normalized()
	
	var is_currently_running = is_on_floor() and is_running and movement_input != Vector2.ZERO
	if is_currently_running && time_elapsed >= UPDATE_INTERVAL:
		time_elapsed -= UPDATE_INTERVAL
		@warning_ignore("narrowing_conversion")
		stamina -= stamina_drain_rate * delta
		stamina = clamp(stamina, 0, 100)
	else:
		time_elapsed += delta
		time_elapsed = clamp(time_elapsed, 0.0, UPDATE_INTERVAL)
	#run_particles.emitting = is_currently_running
	#if is_on_floor() and movement_input:
		#if not $Sounds/StepSound.playing:
			#$Sounds/StepSound.playing = true
	#else:
		#$Sounds/StepSound.playing = false


func jump_logic(delta:float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump") and stamina >= 20:
			velocity.y = -jump_velocity
			do_squash_and_stretch(1.2, 0.15)
			stamina -= 20
	else:
		skin.set_move_state('Jump')
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta


func ability_logic() -> void:
	#actual attack
	if Input.is_action_just_pressed("ability") and stamina >= 20:
		#if weapon_active:
		stamina = skin.attack(stamina)
		#else:
			#if energy >= 20:
				#skin.cast_spell()
				#stop_movement(0.3, 0.8)
				#energy -= 20
	
	#defend
	defend = Input.is_action_pressed("block")
	
	#switch weapon/magic
	#if Input.is_action_just_pressed("switch weapon") and not skin.attacking:
		#weapon_active = not weapon_active
		#skin.switch_weapon(weapon_active)
		#do_squash_and_stretch(1.2, 0.15)
		
	#if Input.is_action_just_pressed("switch spell") and not skin.attacking and not weapon_active:
		#current_spell = spells[spells.keys()[(int(current_spell) + 1) % len(spells)]]
		#ui.update_spell(spells, current_spell)


func stop_movement(start_duration:float, end_duration:float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)


func hit() -> void:
	if not $Timers/InvulTimer.time_left:
		skin.hit()
		stop_movement(0.3,0.3)
		health -= 20.0
		$Timers/InvulTimer.start()


func do_squash_and_stretch(value: float, duration: float = 0.1) -> void:
	var tween = create_tween()
	tween.tween_property(skin, "squash_and_stretch", value, duration)
	tween.tween_property(skin, "squash_and_stretch", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)


func _on_stamina_recovery_timer_timeout() -> void:
	stamina += 1


func pause_logic() -> void:
	if Input.is_action_just_pressed("pause"):
		pause_menu.pause(true)
