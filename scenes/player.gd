extends CharacterBody3D

@onready var camera: Node3D = $Camera

const GRAVITY = 20

@export var speed : int = 5


func _ready() -> void:
	add_to_group("Player")


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_horizontal_movement()
	move_and_slide()


func apply_gravity(delta) -> void:
	if ! is_on_floor():
		velocity.y -= GRAVITY * delta


func handle_horizontal_movement() -> void:
	var InputDir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := InputDir.rotated(- camera.rotation.y)
	
	if InputDir:
		velocity.x = direction.x * speed
		velocity.z = direction.y * speed
	
	else: 
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)
	
