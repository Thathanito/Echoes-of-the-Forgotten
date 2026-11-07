extends Node

@onready var levels: Node3D = $Levels

@onready var level_scene := preload("res://scenes/Levels/test_level.tscn")

func _ready() -> void:
	change_to_scene(level_scene, levels)


func change_to_scene(scene: Resource, target_node: Node) -> void:
	var new_scene = scene.instantiate()
	target_node.add_child(new_scene)
