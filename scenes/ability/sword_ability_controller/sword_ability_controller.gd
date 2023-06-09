extends Node

@export var sword_ability: PackedScene

var base_damage = 5
var additional_damage_percent = 1
var base_wait_time

const MAX_RANGE = 150

@onready var timer = $Timer
@onready var main = get_parent().get_parent().main

# Called when the node enters the scene tree for the first time.
func _ready():
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	main = get_parent().get_parent().get_parent().get_parent()
	main.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	if main == null:
		main = get_parent().get_parent().main
	var player = main.get_player() as Node2D
	if player == null:
		return
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(enemy: Node2D): 
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)
		
	if enemies.size() == 0:
		return
	
	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)
	
	var sword_instance = sword_ability.instantiate() as SwordAbility
	var foreground_layer = main.get_foreground_layer()
	foreground_layer.add_child(sword_instance)
	sword_instance.hitbox_component.damage = base_damage * additional_damage_percent
	
	sword_instance.global_position = enemies[0].global_position
	sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4
	
	var enemy_direction = enemies[0].global_position - sword_instance.global_position
	sword_instance.rotation = enemy_direction.angle()


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "sword_rate":
		var percent_reduction = current_upgrades["sword_rate"]["quantity"] * upgrade.value1/100.
		timer.wait_time = base_wait_time * (1 - percent_reduction)
	
	elif upgrade.id == "sword_damage":
		additional_damage_percent = 1 + (current_upgrades["sword_damage"]["quantity"] * upgrade.value1/100.)
	
	if "sword" in upgrade.id:
		timer.emit_signal("timeout")
		timer.start()


