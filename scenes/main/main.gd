extends Node

signal experience_vial_collected(number: float)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal player_damaged
signal enemy_killed

@export var end_screen_scene: PackedScene

var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")

# AI stuff
@onready var experience_bar = $ExperienceBar
@onready var arena_time_manager = $ArenaTimeManager
@onready var enemy_manager = $EnemyManager
@onready var experience_manager = $ExperienceManager
@onready var upgrade_manager = $UpgradeManager

var player 


func _ready():
	randomize()
	player = get_node("Entities").get_node("Player")
	player.health_component.died.connect(on_player_died)
	

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()


# TODO CHANGE THIS
func on_player_died():
	player.ai_controller.reward -= 10
#	print("Reward: ", player.ai_controller.get_reward())
	reset()
	MetaProgression.save()

func get_player():
	return get_entities_layer().get_node("Player")


func get_entities_layer():
	return get_node("Entities")


func get_foreground_layer():
	return get_node("Foreground")


func reset():
	player.reset()
	for child in get_entities_layer().get_children():
		if child.is_in_group("enemy") or child.is_in_group("experience_vial"):
			enemy_manager.object_pool.return_node(child)
	arena_time_manager.timer.wait_time = arena_time_manager.time_to_win
	arena_time_manager.timer.start()
	experience_bar.on_experience_updated(0, 1)
	arena_time_manager.reset()
	enemy_manager.reset()
	experience_manager.reset()
	upgrade_manager.reset()
	
	
func emit_experience_vial_collected(number: float):
	experience_vial_collected.emit(number)
	

func emit_enemy_killed():
	enemy_killed.emit()


func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)
	

func emit_player_damaged():
	player_damaged.emit()
	
