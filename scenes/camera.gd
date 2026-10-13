extends Node3D

@onready var _camera = $SpringArm3D/Camera3D as Camera3D
@onready var _camera_pivot = $"." as Node3D


@export_range(0.1, 1.0) var mouse_sensitivity = 0.002
@export var max_tilt_limit := deg_to_rad(35)
@export var min_tilt_limit := deg_to_rad(-45)


func _ready() -> void:
	add_to_group("Camera")


func _physics_process(_delta : float):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			_camera_pivot.rotation.x -= event.screen_relative.y * mouse_sensitivity
			_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, min_tilt_limit, max_tilt_limit)
			_camera_pivot.rotation.y += -event.screen_relative.x * mouse_sensitivity
