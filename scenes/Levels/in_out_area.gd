extends Area3D


#Add global in out state between cam and area to avoid two sided problems
enum STATE {IN, OUT}
@export var current_state : STATE

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		get_tree().call_group("Camera", "move_to_cam_state", current_state)

	match current_state:
		STATE.IN:
			current_state = STATE.OUT
		STATE.OUT:
			current_state = STATE.IN
