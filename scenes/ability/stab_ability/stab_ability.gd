extends Node2D
class_name StabAbility

@onready var hitbox_component: HitboxComponent = $Visuals/HitboxComponent


func _process(_delta):
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	global_position = player.global_position
