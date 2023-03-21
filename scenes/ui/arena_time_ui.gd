extends CanvasLayer

@export var arena_time_manager: Node
@export var experience_manager: Node
@export var enemy_manager: Node
@onready var label = $%Label
@onready var fps = %FPS
@onready var enemy_count_label = %EnemyCount
@onready var level = %Level
@onready var spawn_timer = %SpawnTimer


func _ready():
	if experience_manager != null:
		experience_manager.level_up.connect(on_level_up)
		level.text = "Level: " + str(1)
	
	if !OS.has_feature("debug"):
		fps.visible = false
		enemy_count_label.visible = false
		level.visible = false
		spawn_timer.visible = false


func _process(delta):
	if arena_time_manager == null:
		return
	var time_elapsed = arena_time_manager.get_time_elapsed()
	label.text = format_seconds_to_string(time_elapsed)
	
	
	# Debug
	if OS.has_feature("debug"):
		fps.text = "FPS: " + str(Engine.get_frames_per_second())
		
		var enemy_count = get_tree().get_nodes_in_group("enemy").size()
		enemy_count_label.text = "Enemy count: " + str(enemy_count)
		
		if enemy_manager != null:
			spawn_timer.text = "Spawn timer: %.2f" %enemy_manager.timer.wait_time


func format_seconds_to_string(seconds: float):
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	return str(minutes) + ":" + ("%02d" % floor(remaining_seconds))


func on_level_up(new_level: int):
	level.text = "Level: " + str(new_level)
