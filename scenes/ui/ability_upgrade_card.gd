extends PanelContainer

signal selected

@onready var name_label = %NameLabel
@onready var description_label = %DescriptionLabel
@onready var upgrade_icon = %UpgradeIcon

var disabled = false
var id

var ai_controller


func _ready():
	gui_input.connect(on_gui_input)
	mouse_entered.connect(on_mouse_entered)


func _process(delta):
	if disabled:
		return
	
	if ai_controller.click_action == id:
		select_card()


func play_in(delay: float = 0):
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(delay).timeout
	$AnimationPlayer.play("in")


func play_discard():
	$AnimationPlayer.play("discard")


func set_ability_upgrade(upgrade: AbilityUpgrade):
	upgrade_icon.texture = upgrade.icon
	name_label.text = upgrade.name
	var text = upgrade.description
	if "{val1}" in text:
		text = text.replace("{val1}", str(upgrade.value1))
	if "{val2}" in text:
		text = text.replace("{val2}", str(upgrade.value2))
	description_label.text = text


func select_card():
	disabled = true
	$AnimationPlayer.play("selected")
	await $AnimationPlayer.animation_finished
	selected.emit()
	
	for other_card in get_parent().get_children():
		if other_card == self:
			continue
			
		other_card.play_discard()


func on_gui_input(event: InputEvent):
	if disabled:
		return
		
	if event.is_action_pressed("left_click"):
		select_card()
	
	
func _unhandled_key_input(event):
	if disabled:
		return
	
	if id == 0:
		if event.is_action_pressed("select_first"):
			select_card()
	elif id == 1:
		if event.is_action_pressed("select_second"):
			select_card()
	elif id == 2:
		if event.is_action_pressed("select_third"):
			select_card()

func on_mouse_entered():
	if disabled:
		return
		
	$HoverAnimationPlayer.play("hover")
