extends Node2D
class_name  SpearAbility

@onready var hitbox_component: HitboxComponent = $HitboxComponent

var base_speed = 400
var direction


func _ready():
	$DurationTimer.timeout.connect(on_timer_timeout)


func _process(delta):
	global_position += base_speed * direction * delta


func on_timer_timeout():
	queue_free()
