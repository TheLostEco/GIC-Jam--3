extends CharacterBody2D

@export var max_horizontal_speed: float = 500.0
@export var horizontal_acceleration_time: float = 0.15
@export var horizontal_deceleration_time: float = 0.2
@export var horizontal_stop_threshold: float = 0.5

@export var gravity_strength: float = 900.0
@export var jump_velocity: float = -300.0
@export var max_jumps: int = 2
@export var jump_input_action: String = "jump"

@export var dash_speed: float = 900.0
@export var dash_duration: float = 0.25
@export var dash_cooldown: float = 0.5
@export var dash_input_action: String = "dash"

var horizontal_acceleration_rate: float
var horizontal_deceleration_rate: float

var horizontal_input: float = 0.0
var jump_count: int = 0

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var last_dash_direction: float = 0.0

func _ready() -> void:
	horizontal_acceleration_rate = max_horizontal_speed / horizontal_acceleration_time if horizontal_acceleration_time > 0 else 99999.0
	horizontal_deceleration_rate = max_horizontal_speed / horizontal_deceleration_time if horizontal_deceleration_time > 0 else 99999.0

	if !InputMap.has_action(jump_input_action):
		push_warning( jump_input_action)
	if !InputMap.has_action(dash_input_action):
		push_warning( dash_input_action)

func _input(event: InputEvent) -> void:
	horizontal_input = Input.get_axis("move_left", "move_right")

	if event.is_action_pressed(jump_input_action) and jump_count < max_jumps:
		velocity.y = 0.0
		velocity.y = jump_velocity
		jump_count += 1

	if event.is_action_pressed(dash_input_action) and not is_dashing and dash_cooldown_timer <= 0.0:
		if abs(horizontal_input) > 0.001 or abs(velocity.x) > horizontal_stop_threshold:
			is_dashing = true
			dash_timer = dash_duration
			dash_cooldown_timer = dash_cooldown
			last_dash_direction = horizontal_input if abs(horizontal_input) > 0.001 else (1.0 if velocity.x >= 0 else -1.0)
			# Prevent dash if no direction or if player is completely stopped and no input
			if abs(last_dash_direction) < 0.001:
				is_dashing = false # Cancel dash if no direction can be determined
				dash_cooldown_timer = 0.0 # Don't apply cooldown
		else:
			is_dashing = false # If no input and not moving, prevent dash
			dash_cooldown_timer = 0.0

func _physics_process(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			velocity.x = move_toward(velocity.x, horizontal_input * max_horizontal_speed, horizontal_acceleration_rate * delta * 2)
		else:
			velocity.x = last_dash_direction * dash_speed
			move_and_slide()
			return

	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer < 0.0:
			dash_cooldown_timer = 0.0

	if !is_on_floor():
		velocity.y += gravity_strength * delta
	else:
		if velocity.y > 0:
			velocity.y = 0.0
		jump_count = 0

	var current_x_velocity: float = velocity.x
	var target_x_velocity: float = horizontal_input * max_horizontal_speed

	var applied_horizontal_rate: float
	if abs(horizontal_input) > 0.001:
		applied_horizontal_rate = horizontal_acceleration_rate
	else:
		applied_horizontal_rate = horizontal_deceleration_rate

	var new_x_velocity: float = move_toward(current_x_velocity, target_x_velocity, applied_horizontal_rate * delta)

	if abs(new_x_velocity) < horizontal_stop_threshold:
		new_x_velocity = 0.0

	velocity.x = new_x_velocity

	move_and_slide()
