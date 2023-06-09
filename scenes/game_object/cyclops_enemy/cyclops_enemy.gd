extends CharacterBody2D

@onready var velocity_component = $VelocityComponent
@onready var health_component = $HealthComponent
@onready var visuals = $Visuals
@onready var collision = $CollisionShape2D
@onready var main = get_parent().get_parent()

var is_moving = false
	

func _physics_process(delta):
	# Performance hack
#	if Performance.get_monitor(Performance.TIME_FPS) < 50:
#		if randi() % 2 == 0:
#			return
	
	if main == null:
		main = get_parent().get_parent()
	if is_moving:
		var dir = velocity_component.get_direction_to_player()
		velocity_component.accelerate_in_direction(dir)
	else:
		velocity_component.decelerate()
	
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func disable_collision(amount: float):
	if randf() < amount:
		collision.call_deferred("set", "disabled", true)
		$AnimationPlayer.stop()


func set_is_moving(moving: bool):
	is_moving = moving
