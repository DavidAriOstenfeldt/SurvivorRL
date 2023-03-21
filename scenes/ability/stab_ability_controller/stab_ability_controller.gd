extends Node

@export var stab_ability: PackedScene

var base_damage = 10
var additional_damage_percent = 1
var base_wait_time
var stab_amount = 1
var stabs_left = stab_amount

@onready var timer = $Timer
@onready var repeat_timer = $RepeatTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	timer.emit_signal("timeout")
	repeat_timer.timeout.connect(on_repeat_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	for i in range(min(stab_amount, 2)):
		if i%2 == 0:
			var player = get_tree().get_first_node_in_group("player") as Node2D
			if player == null:
				return
			
			var stab_instance = stab_ability.instantiate() as StabAbility
			var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
			foreground_layer.add_child(stab_instance)
			stab_instance.hitbox_component.damage = base_damage * additional_damage_percent
			
			stab_instance.global_position = player.global_position
			stab_instance.scale.x = player.visuals.scale.x
			
			stabs_left -= 1
		else:
			var player = get_tree().get_first_node_in_group("player") as Node2D
			if player == null:
				return
			
			var stab_instance = stab_ability.instantiate() as StabAbility
			var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
			foreground_layer.add_child(stab_instance)
			stab_instance.hitbox_component.damage = base_damage * additional_damage_percent
			
			stab_instance.global_position = player.global_position
			stab_instance.scale.x = player.visuals.scale.x * -1
			
			stabs_left -= 1
			check_stabs_left()


func on_repeat_timer_timeout():
	for i in range(min(stabs_left, 2)):
		if i%2 == 0:
			var player = get_tree().get_first_node_in_group("player") as Node2D
			if player == null:
				return
			
			var stab_instance = stab_ability.instantiate() as StabAbility
			var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
			foreground_layer.add_child(stab_instance)
			stab_instance.hitbox_component.damage = base_damage * additional_damage_percent
			
			stab_instance.global_position = player.global_position
			stab_instance.scale.x = player.visuals.scale.x
			
			stabs_left -= 1
			if stabs_left == 0:
				stabs_left = stab_amount
		else:
			var player = get_tree().get_first_node_in_group("player") as Node2D
			if player == null:
				return
			
			var stab_instance = stab_ability.instantiate() as StabAbility
			var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
			foreground_layer.add_child(stab_instance)
			stab_instance.hitbox_component.damage = base_damage * additional_damage_percent
			
			stab_instance.global_position = player.global_position
			stab_instance.scale.x = player.visuals.scale.x * -1
			
			stabs_left -= 1
			check_stabs_left()


func check_stabs_left():
	if stabs_left > 0:
		repeat_timer.start()
	else:
		stabs_left = stab_amount


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "stab_rate":
		var percent_reduction = current_upgrades["stab_rate"]["quantity"] * upgrade.value1/100.
		timer.wait_time = base_wait_time * (1 - percent_reduction)
	
	elif upgrade.id == "stab_damage":
		additional_damage_percent = 1 + (current_upgrades["stab_damage"]["quantity"] * upgrade.value1/100.)
	
	elif upgrade.id == "stab_amount":
		stab_amount += upgrade.value1
		stabs_left = stab_amount
	
	if "stab" in upgrade.id:
		timer.emit_signal("timeout")
		timer.start()



