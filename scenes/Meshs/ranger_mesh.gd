extends Node3D

@export var blend_smoothing := 8.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

var current_blend := Vector2.ZERO

func _ready() -> void:
	add_to_group("PlayerMesh")

func travel_state(state: String) -> void:
	state_machine.travel(state)

func handle_blend_space(target: Vector2, delta: float) -> void:
	current_blend = current_blend.lerp(target, 1.0 - exp(-blend_smoothing * delta))
	animation_tree.set("parameters/Locomotion/blend_position", current_blend)
