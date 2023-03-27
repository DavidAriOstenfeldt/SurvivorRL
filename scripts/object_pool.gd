extends Node
class_name ObjectPool

@export var min_load_amount = 10
@export var object_pool: Dictionary = {}

var return_queue: Array = []

func take_node(path: String, packed_scene: PackedScene):
	var object
	if not path in object_pool:
		load_object(path, packed_scene)
		
	object = object_pool[path][0]
	object_pool[path].erase(object)
	
	if len(object_pool[path]) < 1:
		object_pool.erase(path)
	
	return object

func return_node(object):
	if return_queue.has(object):
		return
	return_queue.append(object)


func clean_return_queue():
	while len(return_queue) > 0:
		var object = return_queue.pop_front()
		if object == null:
			return
		var par = object.get_parent()
		if par == null:
			return
		par.remove_child(object)
		if object.has_node("HealthComponent"):
			object.health_component.current_health = object.health_component.max_health
		if object.scene_file_path in object_pool:
			object_pool[object.scene_file_path].append(object)
		else:
			object_pool[object.scene_file_path] = [object]


func load_object(path: String, packed_scene: PackedScene):
	for i in min_load_amount:
		var object = packed_scene.instantiate()
		if path in object_pool:
			object_pool[path].append(object)
		else:
			object_pool[path] = [object]
