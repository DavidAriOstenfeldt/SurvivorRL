extends CanvasLayer

@onready var mains = get_tree().get_nodes_in_group("main")

var arena_time_managers = []
var experience_managers = []
var labels = []

@onready var container = $MarginContainer/TimeHContainer
var theme_resource = preload("res://resources/theme/theme.tres")

@onready var fps = %FPS
@onready var enemy_count = %EnemyCount
@onready var vial_count = %VialCount
@onready var h_box_container = $MarginContainer/HBoxContainer



func _ready():
	for i in range(mains.size()):
		arena_time_managers.append(mains[i].get_node("ArenaTimeManager"))
		experience_managers.append(mains[i].get_node("ExperienceManager"))
		
		var label = Label.new()
		label.theme_type_variation = theme_resource.get_type_variation_list("Label")[1]
		container.add_child(label)
		labels.append(label)


func _process(delta):
	for i in range(arena_time_managers.size()):
		if arena_time_managers[i] == null:
			return
			
		var time_elapsed = arena_time_managers[i].get_time_elapsed()
		labels[i].text = "%s \n %s" % [format_seconds_to_string(time_elapsed), experience_managers[i].current_level]
	
	if Engine.get_process_frames() % 30:
		fps.text = "FPS: %s" % Engine.get_frames_per_second()
		enemy_count.text = "Enemies: %s" % get_tree().get_nodes_in_group("enemy").size()
		vial_count.text = "Vials: %s" % get_tree().get_nodes_in_group("experience_vial").size()
		


func format_seconds_to_string(seconds: float):
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	return str(minutes) + ":" + ("%02d" % floor(remaining_seconds))
