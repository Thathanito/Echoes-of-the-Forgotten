extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		get_tree().call_group("Camera", "move_to_cam_state")
