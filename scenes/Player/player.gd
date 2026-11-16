extends CharacterBody3D

@onready var camera: Node3D = $Camera
@onready var mesh: Node3D = $RangerMesh

const GRAVITY = 20
@export var jump_force := 7
const LAND_DURATION := 0.6667

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
enum STATES {IDLE, WALK, RUN, JUMP, DODGE, LAND}
var current_state : STATES

#Rotation_modes
enum RMODE {FREE, LOCK}
var current_rmode : RMODE

var anims := {
	"Idle": "idle",
	"Walk": "walk",
	"Run": "run",
	"Locked": "locked",
	"Jump": "jump",
	"Dodge_forward": "dodge_f",
	"Dodge_backward": "dodge_b",
	"Locked_dodge": "dodge_blend_space"
	}
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
	if current_state == STATES.LAND:
		return   # locked until the landing finishes

	if not is_on_floor():
		enter_state(STATES.JUMP)
	elif InputDir != Vector2.ZERO:
		enter_state(STATES.RUN if Input.is_action_pressed("Run") else STATES.WALK)
	else:
		enter_state(STATES.IDLE)
		
	if Input.is_action_just_pressed("dodge"):
		enter_state(STATES.DODGE)

func enter_state(new_state: STATES) -> void:
	if new_state == current_state:
		return

	exit_state(current_state)

	match new_state:
		STATES.IDLE:
			current_anim = anims["Idle"]
		STATES.WALK:
			current_anim = anims["Walk"]
		STATES.RUN:
			current_anim = anims["Locked"] if current_rmode == RMODE.LOCK else anims["Run"]
		STATES.JUMP:
			current_anim = anims["Jump"]
		STATES.DODGE:
			if current_rmode == RMODE.LOCK:
				current_anim = anims["Locked_dodge"]
			else:
				if current_state == STATES.IDLE:
					current_anim = anims["Dodge_backward"]
				elif current_state == STATES.WALK or current_state == STATES.RUN:
					current_anim = anims["Dodge_forward"]
			
	current_state = new_state

func exit_state(state : STATES) -> void:
	pass


func handle_anim() -> void:
	get_tree().call_group("PlayerMesh", "travel_state", current_anim)

func handle_camera_smoothness(delta : float) -> void:
	get_tree().call_group("Camera", "cam_following", global_position, delta)

func debug() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		match current_rmode:
			RMODE.FREE:
				current_rmode = RMODE.LOCK
			RMODE.LOCK:
				current_rmode = RMODE.FREE
