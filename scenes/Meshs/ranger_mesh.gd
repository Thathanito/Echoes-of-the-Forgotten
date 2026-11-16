extends Node3D

@export var blend_smoothing := 8.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer 
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/Locomotion/playback")

var current_blend := Vector2.ZERO

func _ready() -> void:
	add_to_group("PlayerMesh")

func travel_state(state: String) -> void:
	state_machine.travel(state)

func locomotion_mode(blend_input : float) -> void:
	var tween := create_tween()
	tween.tween_property(animation_tree, "parameters/Blend2/blend_amount", blend_input, 0.2)

func handle_blend_spaces_lock(target : Vector2) -> void:
	animation_tree.set("parameters/Movement/blend_position", target)
	animation_tree.set("parameters/Dodge/blend_position", target)

func fire_dodge(value : bool) -> void:
	if value:
		animation_tree.set("parameters/DodgeShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	else: 
		animation_tree.set("parameters/DodgeShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
