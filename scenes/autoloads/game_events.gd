extends Node

signal experience_vial_collected(number: float)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal player_damaged
signal enemy_killed
signal free_orphans

var object_pool = ObjectPool.new()


func _ready():
	get_tree().set_auto_accept_quit(false)


func _process(delta):
	object_pool.clean_return_queue()
	
	if Input.is_action_just_pressed("print_orphans"):
		print_orphan_nodes()


func emit_experience_vial_collected(number: float):
	experience_vial_collected.emit(number)


func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)


func emit_player_damaged():
	player_damaged.emit()


func emit_enemy_killed():
	enemy_killed.emit()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		free_orphans.emit()
		# await get_tree().create_timer(.1).timeout
		get_tree().quit()
