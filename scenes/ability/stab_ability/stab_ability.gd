extends Node2D
class_name StabAbility

@onready var hitbox_component: HitboxComponent = $Visuals/HitboxComponent
@onready var main = get_parent().get_parent()

func _process(_delta):
	var player = main.get_player() as Node2D
	if player == null:
		return
	global_position = player.global_position
