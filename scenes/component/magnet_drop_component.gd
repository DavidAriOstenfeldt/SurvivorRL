extends Node

@export_range(0, 1) var drop_percent: float = .001
@export var health_component: Node
@export var magnet_scene: PackedScene
@onready var main = owner.get_parent().get_parent()


func _ready():
	(health_component as HealthComponent).died.connect(on_died)


func on_died():
	var adjusted_drop_percent = drop_percent
	# Keeping here if i want to add meta progression...
	# var experience_gain_upgrade_count = MetaProgression.get_upgrade_count("experience_gain")
	# var value = MetaProgression.get_upgrade_value("experience_gain")[0]
	# adjusted_drop_percent = drop_percent * (1 + (experience_gain_upgrade_count) * value)
	
	if randf() > adjusted_drop_percent:
		return
	
	if magnet_scene == null:
		return
	
	if not owner is Node2D:
		return
	
	var spawn_position = (owner as Node2D).global_position
	var magnet_instance = magnet_scene.instantiate() as Node2D
	var entities_layer = main.get_entities_layer()
	entities_layer.add_child(magnet_instance)
	magnet_instance.global_position = spawn_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * 5


