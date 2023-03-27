extends Node

@export_range(0, 1) var drop_percent: float = .5
@export var health_component: HealthComponent
@export var vial_scene: PackedScene
@export_category("Mimic Settings")
@export var is_mimic: bool = false
@export var vial_amount: int = 50
@export var vial_scenes: Array[PackedScene]

@onready var main = owner.get_parent().get_parent()


func _ready():
	(health_component as HealthComponent).died.connect(on_died)


func on_died():
	if !is_mimic:
		var adjusted_drop_percent = drop_percent
		var experience_gain_upgrade_count = MetaProgression.get_upgrade_count("experience_gain")
		var value = MetaProgression.get_upgrade_value("experience_gain")[0]
		adjusted_drop_percent = drop_percent * (1 + (experience_gain_upgrade_count) * value)
		
		if randf() > adjusted_drop_percent:
			return
		
		if vial_scene == null:
			return
		
		if not owner is Node2D:
			return
		
		if main == null:
			main = owner.get_parent().get_parent()
		var spawn_position = (owner as Node2D).global_position
		var vial_instance = vial_scene.instantiate() as Node2D
		var entities_layer = main.get_entities_layer()
		entities_layer.add_child(vial_instance)
		vial_instance.global_position = spawn_position
	else:
		if len(vial_scenes) == 0:
			return
		
		if not owner is Node2D:
			return
		
		var spawn_position = (owner as Node2D).global_position
		var vial_instance: Node2D
		for i in range(vial_amount):
			if randf() > .66:
				vial_instance = main.enemy_manager.object_pool.take_node(vial_scenes[1].resource_path, vial_scenes[1])
			else:
				vial_instance = main.enemy_manager.object_pool.take_node(vial_scenes[0].resource_path, vial_scenes[0])
			
			if main == null:
				main = owner.get_parent().get_parent()
			var entities_layer = main.get_entities_layer()
			entities_layer.add_child(vial_instance)
			vial_instance.global_position = spawn_position
			var target_pos = spawn_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(10,50)
			vial_instance.spawn_animation(target_pos)

