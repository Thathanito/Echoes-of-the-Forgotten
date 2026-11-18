extends CharacterBody3D

@onready var camera: Node3D = $Camera
@onready var mesh: Node3D = $RangerMesh

const GRAVITY = 20
@export var jump_force := 7

const DODGE_DURATION := 0.35
var dash_strength := 10.0
var dash_dir := Vector2.ZERO

@export var ground_friction := 25.0
@export var air_friction := 0.5
@export var ground_accel := 20.0
@export var air_accel := 1.5

var direction : Vector2
var InputDir : Vector2

@export var base_speed : int = 5
@export var run_speed : int = 7

@export var mesh_rotation_speed : float = 10
var last_target_yaw := 0.0 

#States
enum STATES {IDLE, WALK, RUN, JUMP, DODGE, LAND}
var current_state : STATES

#Rotation_modes
enum RMODE {FREE, LOCK}
var current_rmode : RMODE

var anims := {
	"Idle": "Idle",
	"Walk": "Walk",
	"Run": "Run",
	"Jump": "Jump",
	}
var current_anim : String

func _ready() -> void:
	add_to_group("Player")
	current_state = STATES.WALK
	current_rmode = RMODE.FREE
	get_tree().call_group("PlayerMesh", "set_to_lock", false)


func _physics_process(delta: float) -> void:
	handle_vertical_movement(delta)
	handle_horizontal_movement(delta)
	
	handle_state()
	
	handle_rotation(delta)
	handle_anim()
	
	handle_camera_smoothness(delta)
	
	debug()
	
	move_and_slide()


func apply_gravity(delta) -> void:
	if ! is_on_floor():
		velocity.y -= GRAVITY * delta


func handle_vertical_movement(delta) -> void:
	apply_gravity(delta)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force


func handle_horizontal_movement(delta: float) -> void:
	InputDir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = InputDir.rotated(-camera.rotation.y)

	var in_air := current_state == STATES.JUMP  
	var accel := air_accel if in_air else ground_accel
	var friction := air_friction if in_air else ground_friction

	if InputDir != Vector2.ZERO:
		var speed := run_speed if Input.is_action_pressed("Run") else base_speed
		velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
		velocity.z = move_toward(velocity.z, direction.y * speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.z = move_toward(velocity.z, 0.0, friction * delta)


func dash() -> void:
	if InputDir != Vector2.ZERO:
		dash_dir = direction.normalized()
	else:
		var back := -mesh.global_transform.basis.z
		dash_dir = Vector2(back.x, back.z).normalized()
	
	velocity.x += dash_dir.x * dash_strength
	velocity.z += dash_dir.y * dash_strength
	

func handle_rotation(delta: float) -> void:

	if InputDir != Vector2.ZERO:
		match current_rmode:
			RMODE.FREE:
				last_target_yaw = atan2(direction.x, direction.y)
			RMODE.LOCK:
				last_target_yaw = camera.global_rotation.y + PI
		get_tree().call_group("PlayerMesh", "handle_blend_spaces", InputDir)

	mesh.global_rotation.y = lerp_angle(mesh.global_rotation.y, last_target_yaw, mesh_rotation_speed * delta)


func handle_state() -> void:
	if current_state == STATES.DODGE:
		return   # locked until the dodge finishes

	if Input.is_action_just_pressed("dodge") and is_on_floor():
		enter_state(STATES.DODGE)
	elif not is_on_floor():
		enter_state(STATES.JUMP)
	elif InputDir != Vector2.ZERO:
		enter_state(STATES.RUN if Input.is_action_pressed("Run") else STATES.WALK)
	else:
		enter_state(STATES.IDLE)


func enter_state(new_state: STATES) -> void:
	if new_state == current_state:
		return

	var prev_state := current_state
	current_state = new_state
	exit_state(prev_state)

	match new_state:
		STATES.IDLE:
			current_anim = anims["Idle"]
		STATES.WALK:
			current_anim = anims["Walk"]
		STATES.RUN:
			current_anim =  anims["Run"]
		STATES.JUMP:
			current_anim = anims["Jump"]
		STATES.DODGE:
			pass


func exit_state(state : STATES) -> void:
	match state:
		STATES.IDLE:
			pass
		STATES.WALK:
			pass


func _finish_dodge(prev_state: STATES) -> void:
	await get_tree().create_timer(DODGE_DURATION).timeout
	get_tree().call_group("PlayerMesh", "fire_dodge", false)
	enter_state(prev_state)


func handle_anim() -> void:
	get_tree().call_group("PlayerMesh", "locomotion", current_anim)


func handle_camera_smoothness(delta : float) -> void:
	get_tree().call_group("Camera", "cam_following", global_position, delta)


func debug() -> void:
	if Input.is_action_just_pressed("toggle_lock"):
		match current_rmode:
			RMODE.FREE:
				get_tree().call_group("PlayerMesh", "set_to_lock", true)
				current_rmode = RMODE.LOCK
			RMODE.LOCK:
				get_tree().call_group("PlayerMesh", "set_to_lock", false)
				current_rmode = RMODE.FREE
	if Input.is_action_just_pressed("ui_text_delete"):
		get_tree().call_group("PlayerMesh", "get_hit", true)
