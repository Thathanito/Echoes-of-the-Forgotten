extends CharacterBody3D

@onready var camera: Node3D = $Camera
@onready var mesh: Node3D = $RangerMesh


const GRAVITY = 20

var direction : Vector2
var InputDir : Vector2

@export var speed : int = 5
@export var mesh_rotation_speed : float = 10
var last_target_yaw := 0.0 

#States
enum STATES {IDLE, WALK, RUN}
var current_state : STATES

func _ready() -> void:
	add_to_group("Player")
	current_state = STATES.WALK


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_horizontal_movement()
	handle_rotation(InputDir, direction, delta)
	
	debug()
	
	move_and_slide()


func apply_gravity(delta) -> void:
	if ! is_on_floor():
		velocity.y -= GRAVITY * delta


func handle_horizontal_movement() -> void:
	InputDir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = InputDir.rotated(- camera.rotation.y)
	
	if InputDir:
		velocity.x = direction.x * speed
		velocity.z = direction.y * speed
		
	else: 
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)


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


func debug() -> void:
	var anim : String
	if Input.is_action_just_pressed("ui_accept"):
		match current_state:
			STATES.IDLE:
				current_state = STATES.RUN
				anim = "Locomotion"
			STATES.WALK:
				current_state = STATES.RUN
			STATES.RUN:
				current_state = STATES.IDLE
				anim = "Idle"
	get_tree().call_group("PlayerMesh", "travel_state", anim)
