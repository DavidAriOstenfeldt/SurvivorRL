extends AIController2D

var move_action: Vector2 = Vector2.ZERO
var click_action

# BAD HARDCODING
var current_upgrades = []
var selectable_upgrades = [-1, -1, -1]
var upgrade_str_to_id = {"sword":0,
								"sword_damage":1,
								"sword_rate":2,
								"axe":3,
								"axe_rate":4,
								"axe_damage":5,
								"axe_amount":6,
								"anvil":7,
								"anvil_damage":8,
								"anvil_rate":9,
								"anvil_size":10,
								"hammer":11,
								"hammer_amount":12,
								"hammer_damage":13,
								"hammer_time":14,
								"player_pickup_area":15,
								"player_speed":16,
								"spear":17,
								"spear_amount":18,
								"spear_rate":19,
								"stab":20,
								"stab_amount":21,
								"stab_damage":22,
								"stab_rate":23}



@onready var raycast_sensor = get_parent().get_node("EnemySensor")
@onready var terrain_sensor = get_parent().get_node("TerrainSensor")
@onready var pickup_sensor = get_parent().get_node("PickupSensor")

@onready var upgrade_manager = get_parent().get_parent().get_parent().get_node("UpgradeManager")


func _ready():
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	upgrade_manager.selectable_upgrades_picked.connect(on_selectable_upgrades_picked)
	for i in range(24):
		current_upgrades.append(0)
	
	current_upgrades[upgrade_str_to_id["sword"]] += 1
		
	
func get_obs() -> Dictionary:
	# get the players position and velocity in the paddle's frame of reference
	var player_pos = to_local(_player.global_position)
	var player_vel = to_local(_player.velocity)
	var obs = [player_pos.x, player_pos.y, player_vel.x, player_vel.y]
	obs.append_array(raycast_sensor.get_observation()) 
	obs.append_array(terrain_sensor.get_observation())
	obs.append_array(pickup_sensor.get_observation())
	obs.append_array(current_upgrades)
	if len(selectable_upgrades) > 0:
		obs.append_array(selectable_upgrades)
	
	return {"obs":obs}

func get_reward() -> float:	
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"move_action" : {
			"size": 2,
			"action_type": "continuous"
		},
		"click_action" : {
			"size": 1,
			"action_type": "continuous"
		}
		}
	
func set_action(action) -> void:	
	move_action.x = clamp(action["move_action"][0], -1.0, 1.0)
	move_action.y = clamp(action["move_action"][1], -1.0, 1.0)
	
	if get_tree().paused:
		click_action = int(remap(action["click_action"][0], -1, 1, 0, 2))


func on_ability_upgrade_added(upgrade, _current_upgrades):
	current_upgrades[upgrade_str_to_id[upgrade.id]] += 1
	selectable_upgrades = [-1, -1, -1]
	reward += 10


func on_selectable_upgrades_picked(upgrades):
	var i = 0
	for upgrade in upgrades:
		selectable_upgrades[i] = upgrade_str_to_id[upgrade.id]
		i += 0
