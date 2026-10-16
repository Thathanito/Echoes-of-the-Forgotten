extends Node3D


@onready var _camera_pivot = $"." as Node3D
@onready var spring_arm_3d: SpringArm3D = $SpringArm3D
@onready var camera_3d: Camera3D = $SpringArm3D/Camera3D


@export_range(0.1, 1.0) var mouse_sensitivity = 0.002
@export var max_tilt_limit := deg_to_rad(30)
@export var min_tilt_limit := deg_to_rad(-45)


enum CAM_STATES {IN, OUT}
var current_state : CAM_STATES

var in_arm_lenght := 3
var in_h_offset := 0.5
var in_y_pivot_hight := Vector3(0.0, 2.5, 0.0)
var out_arm_lenght := 7
var out_h_offset := 2.5
var out_y_pivot_hight := Vector3(0.0, 5.0, 0.0)

var tween := create_tween()
@export var tween_in_duration : float
@export var tween_out_duration : float

func _ready() -> void:
	add_to_group("Camera")
	current_state = CAM_STATES.OUT
	ease_out()


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
			ease_in()
		CAM_STATES.OUT:
			ease_out()


func ease_in() -> void:
	reset_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween.tween_property(spring_arm_3d, "spring_length", in_arm_lenght, tween_in_duration)
	tween.tween_property(camera_3d, "h_offset", in_h_offset, tween_in_duration)
	tween.tween_property(_camera_pivot, "position", in_y_pivot_hight, tween_in_duration)


func ease_out() -> void:
	reset_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween.tween_property(spring_arm_3d, "spring_length", out_arm_lenght, tween_out_duration)
	tween.tween_property(camera_3d, "h_offset", out_h_offset, tween_out_duration)
	tween.tween_property(_camera_pivot, "position", out_y_pivot_hight, tween_out_duration)


func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
