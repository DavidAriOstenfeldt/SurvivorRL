extends Node

signal arena_difficulty_increased(arena_difficulty: int)

const DIFFICULTY_INTERVAL = 5

@export var end_screen_scene: PackedScene

@onready var timer = $Timer
@onready var main = get_parent()

var arena_difficulty = 0

# AI
@onready var time_to_win = timer.wait_time


func _ready():
	timer.timeout.connect(on_timer_timeout)
	

func _process(delta):
	var next_time_target = timer.wait_time - ((arena_difficulty + 1) * DIFFICULTY_INTERVAL)
	if timer.time_left <= next_time_target:
		arena_difficulty += 1
		arena_difficulty_increased.emit(arena_difficulty)
	


func get_time_elapsed():
	return timer.wait_time - timer.time_left


func reset():
	arena_difficulty = 0

	
# Change this as well
func on_timer_timeout():
	main.player.ai_controller.reward += 50
	main.reset()
	MetaProgression.save_data["win_count"] += 1
	MetaProgression.save()
