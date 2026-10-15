extends CharacterBody3D

@onready var camera: Node3D = $Camera
@onready var mesh: Node3D = $RangerMesh


const GRAVITY = 20

var direction : Vector2
var InputDir : Vector2

@export var base_speed : int = 5
@export var run_speed : int = 7
@export var mesh_rotation_speed : float = 10
var last_target_yaw := 0.0 

#States
enum STATES {IDLE, WALK, RUN}
var current_state : STATES

var anims := ["Idle", "Walk", "Locomotion"]
var current_anim : String

func _ready() -> void:
	add_to_group("Player")
	current_state = STATES.WALK


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_horizontal_movement()
	
	handle_rotation(InputDir, direction, delta)
	handle_anim()
	
	debug()
	
	move_and_slide()


func apply_gravity(delta) -> void:
	if ! is_on_floor():
		velocity.y -= GRAVITY * delta


func handle_horizontal_movement() -> void:
	InputDir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = InputDir.rotated(- camera.rotation.y)
	
	if InputDir:
		var speed : int
		if Input.is_action_pressed("Run"):
			move_to_state(STATES.RUN)
			speed = run_speed
		else:
			move_to_state(STATES.WALK)
			speed = base_speed
		velocity.x = direction.x * speed
		velocity.z = direction.y * speed
		
	else: 
		move_to_state(STATES.IDLE)
		velocity.x = move_toward(velocity.x, 0.0, base_speed)
		velocity.z = move_toward(velocity.z, 0.0, base_speed)


func handle_rotation(input_dir: Vector2, dir: Vector2, delta: float) -> void:

	if input_dir != Vector2.ZERO:
		match current_state:
			STATES.WALK:
				last_target_yaw = atan2(dir.x, dir.y)
			STATES.RUN:
				last_target_yaw = camera.global_rotation.y + PI
				get_tree().call_group("PlayerMesh", "handle_blend_space", input_dir, delta)
			STATES.RUN:
				last_target_yaw = 0.0

	mesh.global_rotation.y = lerp_angle(mesh.global_rotation.y, last_target_yaw, mesh_rotation_speed * delta)

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
				current_anim = anims[2]


func handle_anim() -> void:
		get_tree().call_group("PlayerMesh", "travel_state", current_anim)


func debug() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		pass
