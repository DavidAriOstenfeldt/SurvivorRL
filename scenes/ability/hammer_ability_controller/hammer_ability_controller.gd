extends Node

@export var hammer_ability_scene: PackedScene
@onready var timer = $Timer


var base_damage = 5
var additional_damage_percent = 1
var hammer_amount: int = 2
var duration = 2.5
var additional_duration_percent = 1
var radius = 50
var additional_radius_percent = 1
var base_wait_time


func _ready():
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	timer.emit_signal("timeout")
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var foreground = get_tree().get_first_node_in_group("foreground_layer")
	if foreground == null:
		return
	
	for i in range(hammer_amount):
		var hammer_instance = hammer_ability_scene.instantiate() as Node2D
		foreground.add_child(hammer_instance)
		hammer_instance.radius = radius * additional_radius_percent
		hammer_instance.duration = duration * additional_duration_percent
		hammer_instance.timer.wait_time = duration * additional_duration_percent
		hammer_instance.start_tween(duration * additional_duration_percent)
		hammer_instance.global_position = player.global_position
		hammer_instance.base_rotation = Vector2.RIGHT.rotated(TAU/hammer_amount * i)
		hammer_instance.hitbox_component.damage = base_damage * additional_damage_percent
	
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "hammer_damage":
		additional_damage_percent = 1 + (current_upgrades["hammer_damage"]["quantity"] * upgrade.value1/100.)
	
	elif upgrade.id == "hammer_amount":
		hammer_amount += int(upgrade.value1)
	
	elif upgrade.id == "hammer_range":
		additional_radius_percent = 1 + current_upgrades["hammer_range"]["quantity"] * upgrade.value1/100.
	
	# Not used, cooldown
	elif upgrade.id == "hammer_rate":
		var percent_reduction = current_upgrades["hammer_rate"]["quantity"] * upgrade.value1/100.
		timer.wait_time = base_wait_time * (1 - percent_reduction)
	
	# Not used, duration
	elif upgrade.id == "hammer_duration":
		additional_duration_percent = 1 + current_upgrades["hammer_duration"]["quantity"] * upgrade.value1/100.
	
	# Used, cooldown and duration
	elif upgrade.id == "hammer_time":
		var percent_reduction = current_upgrades["hammer_time"]["quantity"] * upgrade.value1/100.
		timer.wait_time = base_wait_time * (1 - percent_reduction)
		additional_duration_percent = 1 + current_upgrades["hammer_time"]["quantity"] * upgrade.value2/100.
	
	if "hammer" in upgrade.id:
		timer.emit_signal("timeout")
		timer.start()
