extends CharacterBody2D
class_name Player

@export var arena_time_manager: Node

@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar
@onready var abilities = $Abilities
@onready var animation_player = $AnimationPlayer
@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var pickup_area = $PickupArea2D

# AI
@onready var ai_controller = $AIController2D
@onready var start_position = global_position
var start_ability = preload("res://scenes/ability/sword_ability_controller/sword_ability_controller.tscn")


var number_colliding_bodies = 0
var base_speed = 0
var base_pickup_area = Vector2.ONE


func _ready():
	# AI
	ai_controller.init(self)
	
	# Regular
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	base_speed = velocity_component.max_speed
	
	$CollisionArea2D.body_entered.connect(on_body_entered)
	$CollisionArea2D.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_decreased.connect(on_health_decreased)
	health_component.health_changed.connect(on_health_changed)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	
	
	var max_health_quantity = MetaProgression.get_upgrade_count("max_health")
	var value = MetaProgression.get_upgrade_value("max_health")[0]
	health_component.max_health += max_health_quantity * value
	health_component.current_health = health_component.max_health
	
	var pickup_area_quantity = MetaProgression.get_upgrade_count("pickup_area")
	value = MetaProgression.get_upgrade_value("pickup_area")[0]/100.
	pickup_area.scale = pickup_area.scale + (base_pickup_area * pickup_area_quantity * value)
	
	var speed_quantity = MetaProgression.get_upgrade_count("speed")
	value = MetaProgression.get_upgrade_value("speed")[0]/100.
	velocity_component.max_speed = velocity_component.max_speed + (base_speed * speed_quantity * value)
	
	update_health_display()


func _process(delta):
	var movement_vector
	var direction
	if ai_controller.heuristic == "human":
		movement_vector = get_movement_vector()
		direction = movement_vector.normalized()
		velocity_component.accelerate_in_direction(direction)
		velocity_component.move(self)
	else:
		movement_vector = ai_controller.move_action
		direction = movement_vector.normalized()
		velocity_component.accelerate_in_direction(direction)
		velocity_component.move(self)
	
	if movement_vector.x != 0 || movement_vector.y != 0:
		animation_player.play("walk")
	else:
		animation_player.play("RESET")
		
	var move_sign = sign(movement_vector.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_movement, y_movement)


func check_deal_damage():
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
	
	health_component.damage(1)
	damage_interval_timer.start()


func update_health_display():
	health_bar.value = health_component.get_health_percent()


func reset():
	ai_controller.done = true
	ai_controller.needs_reset = true
	ai_controller.reset()
	var max_health_quantity = MetaProgression.get_upgrade_count("max_health")
	var value = MetaProgression.get_upgrade_value("max_health")[0]
	health_component.max_health += max_health_quantity * value
	health_component.current_health = health_component.max_health
	
	var pickup_area_quantity = MetaProgression.get_upgrade_count("pickup_area")
	value = MetaProgression.get_upgrade_value("pickup_area")[0]/100.
	pickup_area.scale = pickup_area.scale + (base_pickup_area * pickup_area_quantity * value)
	
	var speed_quantity = MetaProgression.get_upgrade_count("speed")
	value = MetaProgression.get_upgrade_value("speed")[0]/100.
	velocity_component.max_speed = velocity_component.max_speed + (base_speed * speed_quantity * value)
	
	for child in abilities.get_children():
		child.queue_free()
	
	var inst = start_ability.instantiate()
	abilities.add_child(inst)
	
	global_position = start_position
	
	update_health_display()


func on_body_entered(other_body: Node2D):
	number_colliding_bodies += 1
	check_deal_damage()


func on_body_exited(other_body: Node2D):
	number_colliding_bodies -= 1


func on_damage_interval_timer_timeout():
	check_deal_damage()


func on_health_decreased():
	ai_controller.reward -= 5.0
	GameEvents.emit_player_damaged()
	$HitRandomStreamPlayer.play_random()


func on_health_changed():
	update_health_display()
	
	
func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if ability_upgrade is Ability:
		var ability = ability_upgrade as Ability
		abilities.add_child(ability.ability_controller_scene.instantiate())
	elif ability_upgrade.id == "player_speed":
		velocity_component.max_speed = velocity_component.max_speed + (base_speed * current_upgrades["player_speed"]["quantity"] * .1)
	elif ability_upgrade.id == "player_pickup_area":
		pickup_area.scale = pickup_area.scale + (base_pickup_area * current_upgrades["player_pickup_area"]["quantity"] * 1)
	
	
func on_arena_difficulty_increased(difficulty: int):
	ai_controller.reward += 1.0
	var health_regeneration_quantity = MetaProgression.get_upgrade_count("health_regeneration")
	var value = MetaProgression.get_upgrade_value("health_regeneration")
	var is_interval = (difficulty % (int(value[1])/5)) == 0
	if is_interval:
		health_component.heal(health_regeneration_quantity * value[0])
	
	
	
	
	
