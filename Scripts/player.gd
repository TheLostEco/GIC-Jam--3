extends CharacterBody2D

<<<<<<< Updated upstream
# --- Movement Properties ---
@export var max_horizontal_speed: float = 500.0
=======
>>>>>>> Stashed changes
@export var max_horizontal_speed: float = 200.0
@export var horizontal_acceleration_time: float = 0.15
@export var horizontal_deceleration_time: float = 0.2
@export var horizontal_stop_threshold: float = 0.5

# --- Gravity & Jump Properties ---
@export var gravity_strength: float = 900.0
@export var jump_velocity: float = -300.0
@export var max_jumps: int = 2
@export var jump_input_action: String = "jump"

# --- Dash Properties ---
@export var dash_speed: float = 900.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.5
@export var dash_input_action: String = "dash"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# --- Wall Grab Properties ---
@export var wall_slide_speed: float = 50.0 # How fast the player slides down the wall
@export var wall_grab_input_action: String = "wall_grab" # Input action for grabbing wall
@export var wall_jump_horizontal_push: float = 200.0 # How much horizontal force on wall jump

# --- Internal Variables (Optimized for performance) ---
var horizontal_acceleration_rate: float
var horizontal_deceleration_rate: float

var horizontal_input: float = 0.0
var jump_count: int = 0

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var last_dash_direction: float = 0.0

var is_wall_grabbing: bool = false
var wall_grab_direction: float = 0.0 # Stores which wall (-1 left, 1 right) is being grabbed

func _ready() -> void:
	horizontal_acceleration_rate = max_horizontal_speed / horizontal_acceleration_time if horizontal_acceleration_time > 0 else 99999.0
	horizontal_deceleration_rate = max_horizontal_speed / horizontal_deceleration_time if horizontal_deceleration_time > 0 else 99999.0

	if !InputMap.has_action(jump_input_action):
		push_warning("Jump input action '%s' not found in Project Settings -> Input Map. Please add it!" % jump_input_action)
	if !InputMap.has_action(dash_input_action):
		push_warning("Dash input action '%s' not found in Project Settings -> Input Map. Please add it!" % dash_input_action)
	if !InputMap.has_action(wall_grab_input_action):
		push_warning("Wall Grab input action '%s' not found in Project Settings -> Input Map. Please add it!" % wall_grab_input_action)

func _input(event: InputEvent) -> void:
	horizontal_input = Input.get_axis("move_left", "move_right")
<<<<<<< Updated upstream


	if event.is_action_pressed(jump_input_action):
		if is_wall_grabbing:
			is_wall_grabbing = false
			velocity.y = 0.0 # Reset Y velocity for clean wall jump
			velocity.y = jump_velocity
			velocity.x = -wall_grab_direction * wall_jump_horizontal_push # Push away from the wall
			jump_count = 1 # Consume one jump for wall jump
		elif jump_count < max_jumps:
			velocity.y = 0.0
			velocity.y = jump_velocity
			jump_count += 1
=======
>>>>>>> Stashed changes
	animated_sprite_2d.play("Running")
		
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
			if abs(last_dash_direction) < 0.001:
				is_dashing = false
				dash_cooldown_timer = 0.0
		else:
			is_dashing = false
			dash_cooldown_timer = 0.0
	
	if event.is_action_released(wall_grab_input_action) and is_wall_grabbing:
		is_wall_grabbing = false # Release grab when button is released

func _physics_process(delta: float) -> void:
	# 1. Handle Dash State
	if is_dashing:
		animated_sprite_2d.play("dash")
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			velocity.x = move_toward(velocity.x, horizontal_input * max_horizontal_speed, horizontal_acceleration_rate * delta * 2)
		else:
			velocity.x = last_dash_direction * dash_speed
			move_and_slide()
			return

	# 2. Handle Dash Cooldown
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer < 0.0:
			dash_cooldown_timer = 0.0

	# 3. Check and Handle Wall Grab State (if not dashing)
	var can_wall_grab: bool = false
	if !is_on_floor() and Input.is_action_pressed(wall_grab_input_action):
		# Check if currently touching a wall in the input direction
		if is_on_wall():
			var wall_normal = get_wall_normal()
			# Check if input matches wall direction (e.g., pressing right against a right wall)
			if (horizontal_input > 0 and wall_normal.x < 0) or (horizontal_input < 0 and wall_normal.x > 0):
				can_wall_grab = true
				wall_grab_direction = -wall_normal.x # Store which direction the wall is (1 for right wall, -1 for left wall)
			elif (horizontal_input == 0) and is_wall_grabbing: # Stay grabbed if input is released while grabbed
				can_wall_grab = true

	if is_wall_grabbing and not can_wall_grab: # Release if conditions no longer met
		is_wall_grabbing = false

	if can_wall_grab and not is_wall_grabbing: # Start grabbing
		is_wall_grabbing = true
		jump_count = 1 # Reset jumps to 1 when grabbing a wall, allowing for a wall jump + 1 extra jump

	if is_wall_grabbing:
		velocity.x = 0.0 # Stick to the wall horizontally
		velocity.y = move_toward(velocity.y, wall_slide_speed, gravity_strength * delta) # Slowly slide down
		move_and_slide()
		return # Exit early, skip normal gravity and movement

	# 4. Normal Gravity (only if not dashing or wall grabbing)
	if !is_on_floor():
		velocity.y += gravity_strength * delta
	else:
		if velocity.y > 0:
			velocity.y = 0.0
		jump_count = 0 # Reset jump count when on floor

	# 5. Normal Horizontal Movement (only if not dashing or wall grabbing)
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

	# 6. Final Movement Execution
	move_and_slide()
