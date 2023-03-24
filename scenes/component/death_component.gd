extends Node2D

@export var health_component: HealthComponent
@export var sprite: Sprite2D

@onready var main = owner.get_parent().get_parent()

func _ready():
	$GPUParticles2D.texture = sprite.texture
	health_component.died.connect(on_died)
	

func on_died():
	if owner == null || not owner is Node2D:
		return
	
	if main == null:
		main = owner.get_parent().get_parent()
	
	if owner.is_in_group("enemy"):
		main.emit_enemy_killed()
		
	var spawn_position = owner.global_position
	
	var entities = main.get_entities_layer()
	get_parent().remove_child(self)
	entities.add_child(self)
	
	global_position = spawn_position
	$AnimationPlayer.play("default")
	$HitRandomAudioPlayerComponent.play_random()
	
	
