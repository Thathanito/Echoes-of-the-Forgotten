extends CharacterBody3D

@onready var camera: Node3D = $Camera
@onready var mesh: Node3D = $RangerMesh

const GRAVITY = 20
@export var jump_force := 7

@export var ground_friction := 20.0
@export var air_friction := 0.5
@export var ground_accel := 15.0
@export var air_accel := 1.5

var direction : Vector2
var InputDir : Vector2

@export var base_speed : int = 5
@export var run_speed : int = 7

@export var mesh_rotation_speed : float = 10
var last_target_yaw := 0.0 

#States
enum STATES {IDLE, WALK, RUN, JUMP}
var current_state : STATES

#Rotation_modes
enum RMODE {FREE, LOCK}
var current_rmode : RMODE

var anims := ["Idle", "Walk", "Run", "Locked", "Jump"]
var jmp_anims := ["Jmp_start", "Jmp_idle", "Land"]
var current_anim : String

func _ready() -> void:
	add_to_group("Player")
	current_state = STATES.WALK
	current_rmode = RMODE.FREE


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
	else:
		move_to_state(STATES.IDLE)


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

func handle_rotation(delta: float) -> void:

	if InputDir != Vector2.ZERO:
		match current_rmode:
			RMODE.FREE:
				last_target_yaw = atan2(direction.x, direction.y)
			RMODE.LOCK:
				last_target_yaw = camera.global_rotation.y + PI
				get_tree().call_group("PlayerMesh", "handle_blend_space", InputDir, delta)

	mesh.global_rotation.y = lerp_angle(mesh.global_rotation.y, last_target_yaw, mesh_rotation_speed * delta)

func handle_state() -> void:

	if !is_on_floor():
		move_to_state(STATES.JUMP)
		handle_jmp_anims(jmp_anims[1])
	else:
		if InputDir:
			if Input.is_action_pressed("Run"):
				move_to_state(STATES.RUN)
			else:
				move_to_state(STATES.WALK)
		else:
			move_to_state(STATES.IDLE)

func move_to_state(state : STATES) -> void:
	match state:
			STATES.IDLE:
				current_state = STATES.IDLE
				current_anim = anims[0]
			STATES.WALK:
				current_state = STATES.WALK
				current_anim = anims[1]
			STATES.RUN:
				current_state = STATES.RUN
				if current_rmode == RMODE.FREE:
					current_anim = anims[2]
				else:
					current_anim = anims[3]
			STATES.JUMP:
				current_state = STATES.JUMP
				current_anim = anims[4]


func handle_anim() -> void:
	get_tree().call_group("PlayerMesh", "travel_state", current_anim)

func handle_jmp_anims(anim: String) -> void:
	get_tree().call_group("PlayerMesh", "travel_in_jump", anim)

func handle_camera_smoothness(delta : float) -> void:
	get_tree().call_group("Camera", "cam_following", global_position, delta)

func debug() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		match current_rmode:
			RMODE.FREE:
				current_rmode = RMODE.LOCK
			RMODE.LOCK:
				current_rmode = RMODE.FREE
