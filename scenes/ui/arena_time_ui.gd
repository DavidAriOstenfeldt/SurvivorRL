extends CanvasLayer

@onready var mains = get_tree().get_nodes_in_group("main")

var arena_time_managers = []
var labels = []

@onready var container = $MarginContainer/TimeHContainer
var theme_resource = preload("res://resources/theme/theme.tres")


func _ready():
	for i in range(mains.size()):
		arena_time_managers.append(mains[i].get_node("ArenaTimeManager"))
		
		
		var label = Label.new()
		label.theme_type_variation = theme_resource.get_type_variation_list("Label")[1]
		container.add_child(label)
		labels.append(label)
		
		
		


func _process(delta):
	for i in range(arena_time_managers.size()):
		if arena_time_managers[i] == null:
			return
			
		var time_elapsed = arena_time_managers[i].get_time_elapsed()
		labels[i].text = format_seconds_to_string(time_elapsed)
	


func format_seconds_to_string(seconds: float):
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	return str(minutes) + ":" + ("%02d" % floor(remaining_seconds))
