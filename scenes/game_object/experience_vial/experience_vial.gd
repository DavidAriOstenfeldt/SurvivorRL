extends Node2D

@export var exp_amount: int = 1

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D
@onready var main = get_parent().get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D.area_entered.connect(on_area_entered)
		

func tween_collect(percent: float, start_position: Vector2):
	if main == null:
		main = get_parent().get_parent()
	var player = main.get_player() as Node2D
	if player == null:
		return
	
	global_position = start_position.lerp(player.global_position, percent)
	var direction_from_start = player.global_position - start_position
	
	var target_rotation = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * -get_process_delta_time()))


func collect():
	main.emit_experience_vial_collected(exp_amount)
	main.enemy_manager.object_pool.return_node(self)


func performance_collect(amount: float):
	if randf() < amount:
		main.emit_experience_vial_collected(exp_amount)
		main.enemy_manager.object_pool.return_node(self)


func disable_collision():
	collision_shape_2d.disabled = true
	

func enable_collision():
	collision_shape_2d.disabled = false


func spawn_animation(target_position: Vector2):
	disable_collision()
	var tween = create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_method(tween_spawn.bind(global_position, target_position), 0.0, 1.0, .5)
	tween.tween_property(sprite, "scale", Vector2.ONE*1.1, .25).from(Vector2.ZERO)
	tween.tween_property(sprite, "scale", Vector2.ONE, .25).set_delay(.25)
	tween.chain()
	tween.tween_callback(enable_collision)


func tween_spawn(percent: float, start_position: Vector2, target_position: Vector2):
	if main == null:
		main = get_parent().get_parent()
	var player = main.get_player() as Node2D
	if player == null:
		return
	
	global_position = start_position.lerp(target_position, percent)


func on_area_entered(other_area: Area2D):
	Callable(disable_collision).call_deferred()
	
	var tween = create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, .5)
	tween.tween_property(sprite, "scale", Vector2.ZERO, .05).set_delay(.45)
	tween.chain()
	tween.tween_callback(collect)
	


