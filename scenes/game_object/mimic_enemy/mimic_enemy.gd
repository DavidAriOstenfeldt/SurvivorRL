extends CharacterBody2D

@onready var velocity_component = $VelocityComponent
@onready var health_component = $HealthComponent
@onready var visuals = $Visuals
@onready var animation_player = $AnimationPlayer
@onready var raycasts = $RayCasts
@onready var direction_visualiser = $DirectionVisualiser
@onready var vial_drop_component = $VialDropComponent
@onready var mimic_player = $MimicPlayer
@onready var mimic_player_timer = $MimicPlayer/MimicPlayerTimer
@onready var main = get_parent().get_parent()

var is_moving = false
var is_active = false

var direction = Vector2.ZERO

@export var id_ := 7


func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	mimic_player.play_random()
	mimic_player_timer.timeout.connect(on_mimic_player_timer_timeout)
	mimic_player_timer.wait_time = randi_range(3,8)
	mimic_player_timer.start()


func _process(delta):
	if main == null:
		main = get_parent().get_parent()
	if is_moving:
		var player = main.get_player() as Node2D
		if player == null:
			return
		
		if direction.is_zero_approx():
			direction = (global_position - player.global_position).normalized()
			direction = direction.rotated(randf_range(-PI/2, PI/2))
			
			for ray in raycasts.get_children():
				ray = ray as RayCast2D
				if ray.is_colliding():
					direction = ray.get_collision_normal()
		
		direction_visualiser.target_position = direction * 50
		velocity_component.accelerate_in_direction(direction)
	else:
		direction = Vector2.ZERO
		velocity_component.decelerate()
	
	velocity_component.move(self)


func set_is_moving(moving: bool):
	is_moving = moving


func set_active(active: bool):
	is_active = active
	animation_player.play("active")


func activate():
	animation_player.play("activate")
	mimic_player.play_random()


func disable_collision(amount: float):
	pass


func on_hit():
	$HitRandomAudioPlayerComponent.play_random()
	if !is_active:
		activate()
		

func on_mimic_player_timer_timeout():
	if !is_active:
		mimic_player.play_random()
		
		mimic_player_timer.wait_time = randi_range(5, 15)
		mimic_player_timer.start()
