extends CharacterBody2D

@export var speed := 600
@export var jump_force := -520
@export var gravity := 1800
@export var wall_jump_force := Vector2(400, -500)
@export var max_fall_speed := 1000
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var facing_right := true
var coyote_time := 0.1
var coyote_timer := 0.0
var jump_buffer_time := 0.1
var jump_buffer_timer := 0.0
var last_wall_normal := Vector2.ZERO
var wall_jump_cooldown := 3.0
var wall_jump_timer := 0.0

#Slide-related
var is_sliding := false
var slide_timer := 0.0
var slide_duration := 0.5
var slide_speed := 800
var slide_cooldown := 0.5
var slide_cooldown_timer := 0.0

func _physics_process(delta):
	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")

	if Input.is_action_just_pressed("slide") and is_on_floor() and abs(velocity.x) > 100 and slide_cooldown_timer <= 0:
		is_sliding = true
		slide_timer = slide_duration
		slide_cooldown_timer = slide_cooldown
		velocity.x = (1 if facing_right else -1) * slide_speed
		animation_player.play("slide")

	if is_sliding:
		slide_timer -= delta
		if slide_timer <= 0 or not is_on_floor():
			is_sliding = false

	if not is_sliding:
		var accel: float
		var friction: float
		if is_on_floor():
			accel = 5000
			friction = 1000
		else:
			accel = 3000
			friction = 400
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)

	if direction != 0:
		$Sprite2D.flip_h = direction < 0
		facing_right = direction > 0

	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > max_fall_speed:
			velocity.y = max_fall_speed
	else:
		coyote_timer = coyote_time
		last_wall_normal = Vector2.ZERO
		wall_jump_timer = 0.0

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_force
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	if is_on_wall() and not is_on_floor() and Input.is_action_just_pressed("jump"):
		var wall_normal = get_wall_normal()
		var trying_same_wall = wall_normal == last_wall_normal and wall_jump_timer > 0.0

		if not trying_same_wall:
			velocity = wall_jump_force * Vector2(1 if wall_normal.x > 0 else -1, 1)
			last_wall_normal = wall_normal
			wall_jump_timer = wall_jump_cooldown
			coyote_timer = 0.0
			jump_buffer_timer = 0.0
			velocity.x += wall_normal.x * 200

	if wall_jump_timer > 0:
		wall_jump_timer -= delta
	if coyote_timer > 0:
		coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	if slide_cooldown_timer > 0:
		slide_cooldown_timer -= delta

	move_and_slide()
