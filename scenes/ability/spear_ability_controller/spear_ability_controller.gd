extends Node

@export var spear_ability: PackedScene

@onready var main = get_parent().get_parent().main

var base_damage = 10
var additional_damage_percent = 1
var base_wait_time
var spear_amount = 1

const MAX_RANGE = 300

@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	timer.emit_signal("timeout")
	main = get_parent().get_parent().get_parent().get_parent()
	main.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
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
	
	
	var enemy_direction = enemies[0].global_position - player.global_position
	for i in range(spear_amount):
		var spear_instance = spear_ability.instantiate() as SpearAbility
		var foreground_layer = main.get_foreground_layer()
		foreground_layer.add_child(spear_instance)
		spear_instance.hitbox_component.damage = base_damage * additional_damage_percent
		
		spear_instance.global_position = player.global_position
		
		spear_instance.rotation = enemy_direction.angle()
		spear_instance.direction = enemy_direction.normalized()
		if i > 0:
			spear_instance.global_position += enemy_direction.normalized().orthogonal() * 8*i


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "spear_rate":
		var percent_reduction = current_upgrades["spear_rate"]["quantity"] * upgrade.value1/100.
		timer.wait_time = base_wait_time * (1 - percent_reduction)
	
	elif upgrade.id == "spear_amount":
		spear_amount += upgrade.value1
	
	if "spear" in upgrade.id:
		timer.emit_signal("timeout")
		timer.start()


