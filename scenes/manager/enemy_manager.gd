extends Node

const SPAWN_RADIUS = 375

@export var enemies_to_spawn: int = 1
@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var crab_enemy_scene: PackedScene
@export var cyclops_enemy_scene: PackedScene
@export var green_ghost_enemy_scene: PackedScene
@export var brown_rat_enemy_scene: PackedScene
@export var spider_enemy_scene: PackedScene
@export var grey_ghost_enemy_scene: PackedScene
@export var mimic_enemy_scene: PackedScene
@export_range(0,1) var mimic_spawn_chance: float = .02


@export var arena_time_manager: Node

@onready var timer = $Timer
@onready var main = get_parent()

var base_spawn_time = 0
var enemy_table = WeightedTable.new()

var object_pool = ObjectPool.new()



# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_table.add_item(basic_enemy_scene, 10)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
#	@warning_ignore("integer_division")
#	enemies_to_spawn = int(500/9)
#	on_timer_timeout()
#	enemies_to_spawn = 1


func _process(delta):
	object_pool.clean_return_queue()


func get_spawn_position():
	var player = main.get_player() as Node2D
	if player == null:
		return Vector2.ZERO
	
	var spawn_position = Vector2.ZERO
	# Picks a random point on a circle (radius 1)
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset = random_direction * 20
		
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	
		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
		
	return spawn_position

func reset():
	enemies_to_spawn = 1
	timer.wait_time = base_spawn_time
	enemy_table = WeightedTable.new()
	enemy_table.add_item(basic_enemy_scene, 10)
	


func on_timer_timeout():
	timer.start()
	
	var player = main.get_player() as Node2D
	if player == null:
		return
	
	var entities_layer = main.get_entities_layer()
	var entity_count = entities_layer.get_child_count()
	if entity_count >= 500:
		return
	
	for i in range(enemies_to_spawn):
		var enemy_scene = enemy_table.pick_item()
		var enemy = object_pool.take_node(enemy_scene.resource_path, enemy_scene)
		entities_layer.add_child(enemy)
		enemy.global_position = get_spawn_position()
	

func on_arena_difficulty_increased(arena_difficulty: int):
	# Every 5 seconds increase arena difficulty
	var time_off = .1 / 12 * arena_difficulty
	time_off = min(time_off, .9)
	timer.wait_time = base_spawn_time - time_off
#	print(Time.get_ticks_msec()/1000., " increased difficulty")
#	print("wait time is now ", timer.wait_time)
	
	if randf() < mimic_spawn_chance:
		var enemy_scene = mimic_enemy_scene
		var enemy = enemy_scene.instantiate() as Node2D
		
		var entities_layer = main.get_entities_layer()
		entities_layer.add_child(enemy)
		enemy.global_position = get_spawn_position()
		enemy.health_component.max_health =  enemy.health_component.max_health + arena_difficulty *2
		enemy.health_component.current_health = enemy.health_component.max_health
		enemy.vial_drop_component.vial_amount = enemy.vial_drop_component.vial_amount + arena_difficulty
	
	# X / 5 = arena difficulty at time X
	# 60 / 5 = 12 = at 60 seconds, stuff happens
	if arena_difficulty == 12: # 1:00
		enemy_table.add_item(wizard_enemy_scene, 15)
		enemies_to_spawn += 1
	elif arena_difficulty == 24: # 2:00
		enemy_table.add_item(bat_enemy_scene, 8)
		enemies_to_spawn += 1
	elif arena_difficulty == 48: # 4:00
		enemy_table.remove_item(basic_enemy_scene)
		enemy_table.add_item(crab_enemy_scene, 15)
		enemies_to_spawn += 1
	elif arena_difficulty == 60: # 5:00
		enemy_table.remove_item(wizard_enemy_scene)
		enemy_table.add_item(cyclops_enemy_scene, 10)
		enemies_to_spawn += 1
	elif arena_difficulty == 72: # 6:00
		enemy_table.remove_item(bat_enemy_scene)
		enemy_table.add_item(green_ghost_enemy_scene, 5)
	elif arena_difficulty == 84: # 7:00
		enemy_table.remove_item(crab_enemy_scene)
		enemy_table.add_item(brown_rat_enemy_scene, 15)
	elif arena_difficulty == 96: # 8:00
		enemy_table.remove_item(cyclops_enemy_scene)
		enemy_table.add_item(spider_enemy_scene, 10)	
	elif arena_difficulty == 108: # 9:00
		enemy_table.remove_item(green_ghost_enemy_scene)
		enemy_table.add_item(grey_ghost_enemy_scene, 5)
