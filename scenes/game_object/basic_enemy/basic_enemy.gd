extends Node2D

@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var health_component = $HealthComponent
#@onready var collision = $CollisionShape2D
@onready var avoidance_area = $AvoidanceArea

@export var id_ := 0

@onready var main = get_parent().get_parent()

var dir

var frame_to_process

func _ready():
	dir = velocity_component.get_direction_to_player()
	randomize()
	frame_to_process = randi_range(20, 30)
	
	
func _physics_process(delta):
	# Performance hack (reduces enemy movement speed by 50 % hmmm
#	if Performance.get_monitor(Performance.TIME_FPS) < 50:
#		if randi() % 2 == 0:
#			return
	
	if main == null:
		main = get_parent().get_parent()
	
	if Engine.get_physics_frames() % frame_to_process == 0:
		dir = velocity_component.get_direction_to_player()
		dir += velocity_component.get_avoid_direction(global_position, avoidance_area)
		dir = dir.normalized()
	
	velocity_component.accelerate_in_direction(dir)
	velocity_component.manual_move(self)
	
	var move_sign = sign(velocity_component.velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)
