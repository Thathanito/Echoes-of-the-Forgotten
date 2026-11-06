extends Node3D


@onready var _camera_pivot = $"." as Node3D
@onready var spring_arm_3d: SpringArm3D = $SpringArm3D
@onready var camera_3d: Camera3D = $SpringArm3D/Camera3D


@export var max_tilt_limit := deg_to_rad(30)
@export var min_tilt_limit := deg_to_rad(-45)


enum CAM_STATES {IN, OUT}
var current_state : CAM_STATES

var in_dict := {
	"arm_lenght" : 3.0,
	"h_offset" : 0.75,
	"y_pivot_hight" : Vector3(0.0, 2.5, 0.0)
	}

var out_dict := {
	"arm_lenght" : 7.0,
	"h_offset" : 2.0,
	"y_pivot_hight" : Vector3(0.0, 5.5, 0.0)
	}

var y_offset := 0.0

var tween := create_tween()
@export var tween_in_duration : float
@export var tween_out_duration : float

@export var follow_smoothing := 0.005

func _ready() -> void:
	add_to_group("Camera")
	current_state = CAM_STATES.OUT
	_ease(false)


func _physics_process(delta : float):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Settings.current_input_device == 1:
		controller_input(delta)


#mouse
func _unhandled_input(event: InputEvent) -> void:
	if Settings.current_input_device == 0:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				_camera_pivot.rotation.x -= event.screen_relative.y * Settings.mouse_sensitivity
				_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, min_tilt_limit, max_tilt_limit)
				_camera_pivot.rotation.y += -event.screen_relative.x * Settings.mouse_sensitivity


#controller
func controller_input(delta) -> void:
	var joy_dir := Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	rotate_from_vector(joy_dir * delta * Vector2(Settings.horizontal_acceleration_controler, Settings.vertical_acceleration_controler))


func rotate_from_vector(v : Vector2) -> void:
	if v.length():
		_camera_pivot.rotation.y -= v.x
		_camera_pivot.rotation.x -= v.y
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, min_tilt_limit, max_tilt_limit)

func move_to_cam_state(state : CAM_STATES) -> void:
	match state:
		CAM_STATES.IN:
			current_state = CAM_STATES.IN
			_ease(true)
		CAM_STATES.OUT:
			current_state = CAM_STATES.OUT
			_ease(false)


func _ease(state : bool) -> void:
	reset_tween()

	var dict_name = in_dict if state else out_dict
	var duration = tween_in_duration if state else tween_out_duration

	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween.tween_property(spring_arm_3d, "spring_length", dict_name["arm_lenght"], duration)
	tween.tween_property(camera_3d, "h_offset", dict_name["h_offset"], duration)
	tween.tween_property(self, "y_offset", dict_name["y_pivot_hight"].y, duration)


func cam_following(player_pos : Vector3, delta : float) -> void:
	var target := player_pos + Vector3(0.0, y_offset, 0.0)
	var weight := 1.0 - exp(-follow_smoothing * delta)
	global_position = global_position.lerp(target, weight)


func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
