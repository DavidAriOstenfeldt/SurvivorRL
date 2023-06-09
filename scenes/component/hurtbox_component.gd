extends Area2D
class_name HurtboxComponent

signal hit

@export var health_component: HealthComponent

var floating_text_scene = preload("res://scenes/ui/floating_text.tscn")

@onready var main = get_parent().get_parent().get_parent()

func _ready():
	area_entered.connect(on_area_entered)
	
func on_area_entered(other_area: Area2D):
	if not other_area is HitboxComponent:
		return
	
	if health_component == null:
		return
	
	var hitbox_component = other_area as HitboxComponent
	health_component.damage(hitbox_component.damage)
	
	hit.emit()
	
	if MetaProgression.save_data["damage_numbers"]:
		var floating_text = GameEvents.object_pool.take_node(floating_text_scene.resource_path, floating_text_scene)
		if main == null:
			main = get_parent().get_parent().get_parent()
		main.get_foreground_layer().add_child(floating_text)
		
		floating_text.global_position = global_position + (Vector2.UP * 16)
	
		var format_string = "%0.1f"
		if round(hitbox_component.damage) == hitbox_component.damage:
			format_string = "%0.0f"
			
		floating_text.start(format_string % hitbox_component.damage)
	
	
