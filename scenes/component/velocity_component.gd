extends Node

@export var max_speed: int = 40
@export var acceleration: float = 5
@export var avoidance_factor: float = 0.05

var velocity = Vector2.ZERO
@onready var main = get_parent().main

func get_direction_to_player():
	var owner_node2d = owner as Node2D
	if owner_node2d == null:
		return
	
	if main == null:
		main = get_parent().main
	var player = main.get_player() as Node2D
	if player == null:
		return
	
	var direction = (player.global_position - owner_node2d.global_position).normalized()
	return direction


func accelerate_in_direction(direction: Vector2):
	var desired_velocity = direction * max_speed
	velocity = velocity.lerp(desired_velocity, 1 - exp(-acceleration * get_process_delta_time()))


func get_avoid_direction(self_position: Vector2, area: Area2D):
	if area == null:
		return
	var flock = area.get_overlapping_areas()
	var close := Vector2.ZERO
	for boid in flock:
		close += self_position - boid.global_position
	flock = area.get_overlapping_bodies()
	for boid in flock:
		close += self_position - boid.global_position
	
	return (close * avoidance_factor).normalized()
	


func decelerate():
	accelerate_in_direction(Vector2.ZERO)


func move(character_body: CharacterBody2D):
	character_body.velocity = velocity
	character_body.move_and_slide()
	velocity = character_body.velocity
	

func manual_move(body):
	velocity = velocity.limit_length(max_speed)
	body.global_position += velocity * get_physics_process_delta_time()


