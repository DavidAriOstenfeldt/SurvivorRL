extends Node2D

@onready var velocity_component = $VelocityComponent
@onready var health_component = $HealthComponent
@onready var visuals = $Visuals
@onready var main = get_parent().get_parent()
@onready var avoidance_area = $AvoidanceArea

@export var id_ := 4

var is_moving = false


func _ready():
	GameEvents.free_orphans.connect(on_free_orphans)


func _physics_process(delta):
	# Performance hack
#	if Performance.get_monitor(Performance.TIME_FPS) < 50:
#		if randi() % 2 == 0:
#			return
	
	if main == null:
		main = get_parent().get_parent()
	if is_moving:
		var dir = velocity_component.get_direction_to_player()
		dir += velocity_component.get_avoid_direction(global_position, avoidance_area)
		velocity_component.accelerate_in_direction(dir)
	else:
		velocity_component.decelerate()
	
	velocity_component.manual_move(self)
	
	var move_sign = sign(velocity_component.velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)



func set_is_moving(moving: bool):
	is_moving = moving
	
	
func on_free_orphans():
	if not is_inside_tree():
		queue_free()
