extends Node

@export var axe_ability_scene: PackedScene
@onready var timer = $Timer


var base_damage = 10
var additional_damage_percent = 1
var axe_amount: int = 1
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
	
	for i in range(axe_amount):
		var axe_instance = axe_ability_scene.instantiate() as Node2D
		foreground.add_child(axe_instance)
		axe_instance.global_position = player.global_position
		axe_instance.spawn_position = axe_instance.global_position
		axe_instance.base_rotation = Vector2.RIGHT.rotated(TAU/axe_amount * i)
		axe_instance.hitbox_component.damage = base_damage * additional_damage_percent
	
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "axe_damage":
		additional_damage_percent = 1 + (current_upgrades["axe_damage"]["quantity"] * upgrade.value1/100.)
	
	elif upgrade.id == "axe_amount":
		axe_amount += 1
		
	elif upgrade.id == "axe_rate":
		var percent_reduction = current_upgrades["axe_rate"]["quantity"] * upgrade.value1/100.
		timer.wait_time = base_wait_time * (1 - percent_reduction)
	
	if "axe" in upgrade.id:
		timer.emit_signal("timeout")
		timer.start()
