extends CharacterBody2D

@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var collision = $CollisionShape2D
@onready var health_component = $HealthComponent
@onready var main = get_parent().get_parent()

@export var id_ := 8
var dir
var frame_to_process = randi_range(20, 30)

func _ready():
	dir = velocity_component.get_direction_to_player()

func _physics_process(delta):
	# Performance hack
#	if Performance.get_monitor(Performance.TIME_FPS) < 50:
#		if randi() % 2 == 0:
#			return

	if main == null:
		main = get_parent().get_parent()
		
	if Engine.get_physics_frames() % frame_to_process == 0:
		dir = velocity_component.get_direction_to_player()
		
	velocity_component.accelerate_in_direction(dir)
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func disable_collision(amount: float):
	if randf() < amount:
		collision.call_deferred("set", "disabled", true)
		$AnimationPlayer.stop()
