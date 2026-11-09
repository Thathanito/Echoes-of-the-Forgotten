extends Node3D

@export var blend_smoothing := 8.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var sub_fsm_jump : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/Jump/playback")

var current_blend := Vector2.ZERO

func _ready() -> void:
	add_to_group("PlayerMesh")

func travel_state(state: String) -> void:
	state_machine.travel(state)

func travel_in_jump(state: String) -> void:
	sub_fsm_jump.travel(state)

func handle_blend_space(target: Vector2, delta: float) -> void:
	current_blend = current_blend.lerp(target, 1.0 - exp(-blend_smoothing * delta))
	animation_tree.set("parameters/Locked/blend_position", current_blend)
