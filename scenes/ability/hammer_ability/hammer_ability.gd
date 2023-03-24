extends Node2D



@onready var hitbox_component = $HitboxComponent
@onready var timer: Timer = $HammerDuration
@onready var sprite = $Sprite2D

var base_rotation = Vector2.RIGHT

var duration = 5
var radius = 50

@onready var main = get_parent().get_parent()


func _ready():
	timer.timeout.connect(on_timer_timeout)
	

func start_tween(rotations: float):
	var tween = create_tween()
	tween.tween_method(tween_method, 0.0, rotations, duration)
	timer.start()


func tween_method(rotations: float):
	var current_radius = radius
	var current_direction = base_rotation.rotated(rotations * TAU)
	sprite.rotation = current_direction.angle() + PI/2
	
	var player = main.get_player() as Node2D
	if player == null:
		return
		
	global_position = player.global_position + (current_direction * current_radius)
	#global_position = spawn_position + (current_direction * current_radius)


func on_timer_timeout():
	queue_free()
	
	
