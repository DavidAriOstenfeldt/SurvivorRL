extends CharacterBody2D

@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var collision = $CollisionShape2D


func _ready():
	$HurtboxComponent.hit.connect(on_hit)


func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func disable_collision(amount: float):
	if randf() < amount:
		collision.call_deferred("set", "disabled", true)
		$AnimationPlayer.stop()


func on_hit():
	$HitRandomAudioPlayerComponent.play_random()
