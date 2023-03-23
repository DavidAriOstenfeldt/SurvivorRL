extends Node

@export var end_screen_scene: PackedScene

var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")

# AI stuff
@onready var arena_time_ui = $ArenaTimeUI
@onready var experience_bar = $ExperienceBar
@onready var arena_time_manager = $ArenaTimeManager
@onready var enemy_manager = $EnemyManager
@onready var experience_manager = $ExperienceManager
@onready var upgrade_manager = $UpgradeManager
@onready var player = %Player




func _ready():
	randomize()
	%Player.health_component.died.connect(on_player_died)
	

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


func reset():
	player.reset()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("experience_vial", "queue_free")
	arena_time_ui.on_level_up(1)
	arena_time_manager.timer.wait_time = arena_time_manager.time_to_win
	arena_time_manager.timer.start()
	experience_bar.on_experience_updated(0, 1)
	arena_time_manager.reset()
	enemy_manager.reset()
	experience_manager.reset()
	upgrade_manager.reset()
	
	
	
	
