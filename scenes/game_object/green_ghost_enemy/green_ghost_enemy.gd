extends CharacterBody2D

@onready var velocity_component = $VelocityComponent
@onready var health_component = $HealthComponent
@onready var visuals = $Visuals
@onready var collision = $CollisionShape2D
@onready var main = get_parent().get_parent()

@export var id_ := 5

func _ready():
	$HurtboxComponent.hit.connect(on_hit)


func _process(delta):
	if main == null:
		main = get_parent().get_parent()
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
