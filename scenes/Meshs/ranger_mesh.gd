extends Node3D

@export var blend_speed_up := 6.0
@export var blend_speed_down := 8.0

var current_blend := Vector2.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer 
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var locomotion_fsm: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/Locomotion/playback")


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


func trigger_action(state : String) -> void:
	animation_tree.set("parameters/Actions/transition_request", state)
	animation_tree.set("parameters/ActionShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func lock_blend_space(target: Vector2, delta: float) -> void:
	var speed := blend_speed_down if target.length() < current_blend.length() else blend_speed_up
	current_blend = current_blend.move_toward(target, speed * delta)
	animation_tree.set("parameters/LockRun/blend_position", current_blend)

func set_dodge_direction(dir: Vector2) -> void:
	animation_tree.set("parameters/DodgeSpace/blend_position", dir)
