extends Node

signal experience_updated(current_experience: float, target_experience: float)
signal level_up(new_level: int)

@export var target_experience_growth: float = 1.1

var current_experience = 0
var current_level = 1
@export var target_experience = 1
var main


func _ready():
	main = get_parent()
	main.experience_vial_collected.connect(on_experience_vial_collected)

func increment_experience(number: float):
	current_experience = min(current_experience + number, target_experience)
	experience_updated.emit(current_experience, target_experience)
	if current_experience >= target_experience:
		current_level += 1
		target_experience = (5*current_level) + round(pow(target_experience_growth, current_level))
		current_experience = 0
		experience_updated.emit(current_experience, target_experience)
		level_up.emit(current_level)


func reset():
	current_experience = 0
	current_level = 1
	target_experience = 1


func on_experience_vial_collected(number: float):
	increment_experience(number)
