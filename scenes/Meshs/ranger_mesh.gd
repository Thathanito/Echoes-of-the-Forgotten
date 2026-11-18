extends Node3D

@export var blend_smoothing := 8.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer 
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var locomotion_fsm: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/Locomotion/playback")

var current_blend := Vector2.ZERO

func _ready() -> void:
	add_to_group("PlayerMesh")

func get_hit(death : bool) -> void:
	animation_tree.set("parameters/HitShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	if death:
		animation_tree.set("parameters/HitStates/transition_request", "Death")
	else:
		animation_tree.set("parameters/HitStates/transition_request", "Hit")

func set_to_lock(lock : bool) -> void:
	if lock:
		animation_tree.set("parameters/LocomationState/transition_request", "Run")
	else:
		animation_tree.set("parameters/LocomationState/transition_request", "Walk")

func locomotion(state : String) -> void:
	locomotion_fsm.travel(state)
