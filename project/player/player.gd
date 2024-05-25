extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_group("Player Nodes")
@export var neck: Node3D
@export var head: Node3D
@export var body_standing: CollisionShape3D
@export var body_crouching: CollisionShape3D
@export var raycast_crouching: RayCast3D
@export var camera: Camera3D

@export_group("Movement Speed")
@export var walking_speed: float = 5.0
@export var sprinting_speed: float = 8.0
@export var crouching_speed: float = 3.0
@export var sliding_speed: float = 10.0
@export var sliding_timer_max: float = 1.0
@export var jump_speed: float = 6.0
@export var lerp_speed: float = 10.0
@export var jump_lerp_speed: float = 5.0

@onready var attack_area = $AttackArea/CollisionShape3D

var MOUSE_SENSITIVITY: float = 0.25
var GAMEPAD_JOYSTICK_SENSITIVITY: float = 2
var GAMEPAD_JOYSTICK_DEADZONE: float = 0.2

var mouse_input: Vector2 = Vector2.ZERO

var direction: Vector3 = Vector3.ZERO
var current_speed: float = 5.0
var is_sprinting: bool = false

var crouching_delta: float = 0.6

var is_sliding: bool = false
var sliding_timer: float = 0.0
var sliding_direction: Vector2 = Vector2.ZERO


func _ready():
	attack_area.disabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$"Head/Neck/police-with-gun/AnimationPlayer".play("pistol-whip")


func _input(event):
	# TODO: fix jitter related to mouse movement ?
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		var rotation_camera = Vector2(event.relative.x * MOUSE_SENSITIVITY, event.relative.y * MOUSE_SENSITIVITY)
		trigger_camera_movement(rotation_camera)
		mouse_input = event.relative
		

func trigger_camera_movement(rotation_camera: Vector2):
	if is_sliding:
		neck.rotate_y(deg_to_rad(rotation_camera.x * -1))
		neck.rotation_degrees.y = clamp(neck.rotation_degrees.y, -90, 90)
	else:
		rotate_y(deg_to_rad(rotation_camera.x * -1))
	head.rotate_x(-1 * deg_to_rad(rotation_camera.y))
	head.rotation_degrees.x = clamp(head.rotation_degrees.x, -70, 70)


func _physics_process(delta):
	process_movement(delta)


func process_movement(delta):
	if Input.get_connected_joypads().size() > 0:
		var rotation_camera_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var rotation_camera_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		if abs(rotation_camera_x) > GAMEPAD_JOYSTICK_DEADZONE or abs(rotation_camera_y) > GAMEPAD_JOYSTICK_DEADZONE:
			var camera_movement = Vector2(rotation_camera_x * GAMEPAD_JOYSTICK_SENSITIVITY, rotation_camera_y * GAMEPAD_JOYSTICK_SENSITIVITY)
			trigger_camera_movement(camera_movement)
			mouse_input = camera_movement * 2
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if is_on_floor() and Input.is_action_pressed("movement_crouch"):
		if is_sprinting and input_dir != Vector2.ZERO:
			is_sliding = true
			sliding_timer = sliding_timer_max
			sliding_direction = input_dir
		else:
			current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		is_sprinting = false
		
		head.position.y = lerp(head.position.y, -crouching_delta, delta * lerp_speed)
		body_standing.disabled = true
		body_crouching.disabled = false
	elif not raycast_crouching.is_colliding():
		head.position.y = lerp(head.position.y, 0.0, delta * lerp_speed)
		body_standing.disabled = false
		body_crouching.disabled = true
		stop_sliding()
	
		if Input.is_action_pressed("movement_sprint"):
			current_speed = lerp(current_speed, sprinting_speed, delta * lerp_speed)
			is_sprinting = true
		else:
			current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)
			is_sprinting = false
	else:
		# crouching while not pressing button and in a place where player cannot get up
		current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		
	if is_on_floor() and Input.is_action_just_pressed("movement_jump"):
		velocity.y = jump_speed
		stop_sliding()
	
	if is_sliding:
		current_speed = (sliding_timer + 0.2) * sliding_speed
		sliding_timer -= delta
		if sliding_timer <= 0:
			stop_sliding()
	
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	if is_sliding:
		direction = (transform.basis * Vector3(sliding_direction.x, 0, sliding_direction.y)).normalized()
	elif is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	elif input_dir != Vector2.ZERO:
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * jump_lerp_speed)
		
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	# this should not be here! Should be in the player itself but I am lazy
	if Input.is_action_pressed("attack"):
		$"Head/Neck/police-with-gun/AnimationPlayer".play("pistol-whip")
		attack_area.disabled = false
	
	move_and_slide()
	
func stop_sliding():
	is_sliding = false
	rotate_y(neck.rotation.y)
	neck.rotation.y = 0.0
	
func _on_attack_area_body_entered(body):
	body._on_hit()
	
func _on_animation_finished(animation_name):
	if animation_name == "pistol-whip":
		attack_area.disabled = true
	
