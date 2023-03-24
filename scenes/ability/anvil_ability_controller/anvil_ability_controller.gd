extends Node

const BASE_RANGE = 100
const BASE_DAMAGE = 15

@export var anvil_ability_scene: PackedScene
@onready var timer = $Timer
@onready var main = get_parent().get_parent().main

var base_wait_time
var additional_size_percent = 1
var additional_damage_percent = 1

func _ready():
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	timer.emit_signal("timeout")
	
	main = get_parent().get_parent().get_parent().get_parent()
	main.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	if main == null:
		main = get_parent().get_parent().main
	var player = main.get_player() as Node2D
	if player == null:
		return
		
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var spawn_position = player.global_position + direction * randf_range(0, BASE_RANGE)
	
	
	
	var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1)
	var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	if !result.is_empty():
		spawn_position = result["position"]
		
	var anvil_ability = anvil_ability_scene.instantiate()
	main.get_foreground_layer().add_child(anvil_ability)
	anvil_ability.global_position = spawn_position
	anvil_ability.hitbox_component.damage = BASE_DAMAGE * additional_damage_percent
	anvil_ability.scale = Vector2.ONE * additional_size_percent
	
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "anvil_rate":
		var percent_reduction = current_upgrades["anvil_rate"]["quantity"] * upgrade.value1/100.
		timer.wait_time = base_wait_time * (1 - percent_reduction)
		
	elif upgrade.id == "anvil_size":
		additional_size_percent = 1 + (current_upgrades["anvil_size"]["quantity"] * upgrade.value1/100.)
		
	elif upgrade.id == "anvil_damage":
		additional_damage_percent = 1 + (current_upgrades["anvil_damage"]["quantity"] * upgrade.value1/100.)
	
	if "anvil" in upgrade.id:
		timer.emit_signal("timeout")
		timer.start()
		

