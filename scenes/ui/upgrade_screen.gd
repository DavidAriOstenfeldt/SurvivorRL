extends CanvasLayer

signal upgrade_selected(upgrade: AbilityUpgrade)

@export var upgrade_card_scene: PackedScene

@onready var card_container = $%CardContainer

var ai_controller

func _ready():
	get_tree().paused = false


func set_ability_upgrades(upgrades: Array[AbilityUpgrade]):
	var delay = 0
	var i = 0
	for upgrade in upgrades:
		var card_instance = upgrade_card_scene.instantiate()
		card_instance.ai_controller = ai_controller
		card_container.add_child(card_instance)
		card_instance.set_ability_upgrade(upgrade)
		card_instance.play_in(delay)
		card_instance.id = i
		card_instance.selected.connect(on_upgrade_selected.bind(upgrade))
		delay += 0
		i += 1


func on_upgrade_selected(upgrade: AbilityUpgrade):
	upgrade_selected.emit(upgrade)
	$AnimationPlayer.play("out")
	await $AnimationPlayer.animation_finished
	get_tree().paused = false
	queue_free()
