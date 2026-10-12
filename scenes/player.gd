extends CharacterBody3D

const GRAVITY = 20

@export var speed : int = 5


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_horizontal_movement()
	move_and_slide()


func apply_gravity(delta) -> void:
	if ! is_on_floor():
		velocity.y -= GRAVITY * delta


func handle_horizontal_movement() -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized()
	var horizontal := Vector2.ZERO
	
	if dir:
		horizontal.x = dir.x * speed
		horizontal.y = dir.y * speed
	
	else: 
		horizontal = Vector2.ZERO
	
	velocity.x = horizontal.x
	velocity.z = horizontal.y
