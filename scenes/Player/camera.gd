extends Node3D


@onready var _camera_pivot = $"." as Node3D
@onready var spring_arm_3d: SpringArm3D = $SpringArm3D
@onready var camera_3d: Camera3D = $SpringArm3D/Camera3D


@export_range(0.1, 1.0) var mouse_sensitivity = 0.002
@export var max_tilt_limit := deg_to_rad(30)
@export var min_tilt_limit := deg_to_rad(-45)


enum CAM_STATES {IN, OUT}

var in_arm_lenght := 3
var in_h_offset := 0.5
var in_y_pivot_hight := 2.5
var out_arm_lenght := 7
var out_h_offset := 2.5
var out_y_pivot_hight := 5

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


func move_to_cam_state(state : CAM_STATES) -> void:
	match state:
		CAM_STATES.IN:
			spring_arm_3d.spring_length = in_arm_lenght
			camera_3d.h_offset = in_h_offset
			_camera_pivot.position.y = in_y_pivot_hight
		CAM_STATES.OUT:
			spring_arm_3d.spring_length = out_arm_lenght
			camera_3d.h_offset = out_h_offset
			_camera_pivot.position.y = out_y_pivot_hight
