extends Node

@onready var main = get_parent()

@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene

signal selectable_upgrades_picked(chosen_upgrades)

var current_upgrades = {}
var upgrade_pool: WeightedTable = WeightedTable.new()

var ai_controller

# Abilities + ability upgrades
var upgrade_axe = preload("res://resources/upgrades/axe.tres")
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_axe_rate = preload("res://resources/upgrades/axe_rate.tres")
var upgrade_axe_amount = preload("res://resources/upgrades/axe_amount.tres")

var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")

var upgrade_anvil = preload("res://resources/upgrades/anvil.tres")
var upgrade_anvil_rate = preload("res://resources/upgrades/anvil_rate.tres")
var upgrade_anvil_damage = preload("res://resources/upgrades/anvil_damage.tres")
var upgrade_anvil_size = preload("res://resources/upgrades/anvil_size.tres")

var upgrade_hammer = preload("res://resources/upgrades/hammer.tres")
var upgrade_hammer_damage = preload("res://resources/upgrades/hammer_damage.tres")
var upgrade_hammer_amount = preload("res://resources/upgrades/hammer_amount.tres")
var upgrade_hammer_time = preload("res://resources/upgrades/hammer_time.tres")
#var upgrade_hammer_range = preload("res://resources/upgrades/hammer_range.tres")
#var upgrade_hammer_duration = preload("res://resources/upgrades/hammer_duration.tres")
#var upgrade_hammer_rate = preload("res://resources/upgrades/hammer_rate.tres")

var upgrade_spear = preload("res://resources/upgrades/spear.tres")
var upgrade_spear_amount = preload("res://resources/upgrades/spear_amount.tres")
var upgrade_spear_rate = preload("res://resources/upgrades/spear_rate.tres")

var upgrade_stab = preload("res://resources/upgrades/stab.tres")
var upgrade_stab_damage = preload("res://resources/upgrades/stab_damage.tres")
var upgrade_stab_rate = preload("res://resources/upgrades/stab_rate.tres")
var upgrade_stab_amount = preload("res://resources/upgrades/stab_amount.tres")

# Player upgrades
var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")
var upgrade_player_pickup_area = preload("res://resources/upgrades/player_pickup_area.tres")


func _ready():
	upgrade_pool.add_item(upgrade_axe, 8)
	upgrade_pool.add_item(upgrade_anvil, 8)
	upgrade_pool.add_item(upgrade_hammer, 8)
	upgrade_pool.add_item(upgrade_spear, 8)
	upgrade_pool.add_item(upgrade_stab, 8)
	
	upgrade_pool.add_item(upgrade_sword_rate, 8)
	upgrade_pool.add_item(upgrade_sword_damage, 10)
	
	upgrade_pool.add_item(upgrade_player_speed, 5)
	upgrade_pool.add_item(upgrade_player_pickup_area, 5)
	
	experience_manager.level_up.connect(on_level_up)
	
	# AI
	ai_controller = main.get_player().get_node("AIController2D")

func apply_upgrade(upgrade: AbilityUpgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
	
	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity == upgrade.max_quantity:
			upgrade_pool.remove_item(upgrade)
	
	update_upgrade_pool(upgrade)
	main.emit_ability_upgrade_added(upgrade, current_upgrades)


func update_upgrade_pool(chosen_upgrade: AbilityUpgrade):
	if chosen_upgrade.id == upgrade_axe.id:
		upgrade_pool.add_item(upgrade_axe_damage, 5)
		upgrade_pool.add_item(upgrade_axe_rate, 5)
		upgrade_pool.add_item(upgrade_axe_amount, 2)
	
	if chosen_upgrade.id == upgrade_anvil.id:
		upgrade_pool.add_item(upgrade_anvil_rate, 5)
		upgrade_pool.add_item(upgrade_anvil_damage, 5)
		upgrade_pool.add_item(upgrade_anvil_size, 5)
	
	if chosen_upgrade.id == upgrade_hammer.id:
		upgrade_pool.add_item(upgrade_hammer_amount, 2)
		upgrade_pool.add_item(upgrade_hammer_damage, 5)
		upgrade_pool.add_item(upgrade_hammer_time, 5)
#		upgrade_pool.add_item(upgrade_hammer_range, 5)
#		upgrade_pool.add_item(upgrade_hammer_rate, 10005)
#		upgrade_pool.add_item(upgrade_hammer_duration, 10005)
	
	if chosen_upgrade.id == upgrade_spear.id:
		upgrade_pool.add_item(upgrade_spear_amount, 2)
		upgrade_pool.add_item(upgrade_spear_rate, 5)
		
	if chosen_upgrade.id == upgrade_stab.id:
		upgrade_pool.add_item(upgrade_stab_damage, 5)
		upgrade_pool.add_item(upgrade_stab_rate, 5)
		upgrade_pool.add_item(upgrade_stab_amount, 2)
		

func pick_upgrades():
	var chosen_upgrades: Array[AbilityUpgrade] = []
	for i in 3:
		if upgrade_pool.items.size() == chosen_upgrades.size():
			break
			
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrades)
		chosen_upgrades.append(chosen_upgrade)
	
	return chosen_upgrades

func reset():
	current_upgrades = {}
	upgrade_pool = WeightedTable.new()
	upgrade_pool.add_item(upgrade_axe, 8)
	upgrade_pool.add_item(upgrade_anvil, 8)
	upgrade_pool.add_item(upgrade_hammer, 8)
	upgrade_pool.add_item(upgrade_spear, 8)
	upgrade_pool.add_item(upgrade_stab, 8)
	
	upgrade_pool.add_item(upgrade_sword_rate, 8)
	upgrade_pool.add_item(upgrade_sword_damage, 10)
	
	upgrade_pool.add_item(upgrade_player_speed, 5)
	upgrade_pool.add_item(upgrade_player_pickup_area, 5)


# TODO: FIX THIS TO WORK WITH MULTIPLE AGENTS
func on_level_up(current_level: int):
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	upgrade_screen_instance.ai_controller = ai_controller
	add_child(upgrade_screen_instance)
	var chosen_upgrades = pick_upgrades()
	
	var upgrade_ids = []
	for upgrade in chosen_upgrades:
		upgrade_ids.append(upgrade.id)
	selectable_upgrades_picked.emit(chosen_upgrades)
	
	upgrade_screen_instance.set_ability_upgrades(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)


func on_upgrade_selected(upgrade: AbilityUpgrade):
	apply_upgrade(upgrade)
