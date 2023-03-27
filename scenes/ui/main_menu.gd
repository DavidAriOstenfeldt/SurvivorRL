extends CanvasLayer

var options_scene = preload("res://scenes/ui/options_menu.tscn")
var main_scene = preload("res://scenes/main/main.tscn")
var meta_menu = preload("res://scenes/ui/meta_menu.tscn")

@onready var panel_container = %PanelContainer
@onready var h_box_container = %HBoxContainer



func _ready():
	panel_container.pivot_offset = panel_container.size/2
	h_box_container.pivot_offset = h_box_container.size/2
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(h_box_container, "scale", Vector2.ZERO, 0)
	
	tween.tween_property(panel_container, "scale", Vector2.ONE, .5)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(.5)
	
	tween.tween_property(h_box_container, "scale", Vector2.ONE, .5)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(.1)

	
	$%PlayButton.pressed.connect(on_play_pressed)
	$%UpgradesButton.pressed.connect(on_upgrades_pressed)
	$%OptionsButton.pressed.connect(on_options_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)
	
	if MetaProgression.save_data["windowed"] == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	
	var bus_index = AudioServer.get_bus_index("sfx")
	var volume_db = linear_to_db(MetaProgression.save_data["sound_volume"])
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	
	bus_index = AudioServer.get_bus_index("music")
	volume_db = linear_to_db(MetaProgression.save_data["music_volume"])
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	
	%WinsLabel.text = "Total Wins: " + str(MetaProgression.save_data["win_count"])
	%DefeatsLabel.text = "Total Defeats: " + str(MetaProgression.save_data["loss_count"])
	
func on_play_pressed():
	ScreenTransition.play_transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_packed(main_scene)


func on_upgrades_pressed():
	ScreenTransition.play_transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_packed(meta_menu)


func on_options_pressed():
	ScreenTransition.play_transition()
	await ScreenTransition.transitioned_halfway
	
	var options_instance = options_scene.instantiate()
	add_child(options_instance)
	options_instance.back_pressed.connect(on_options_closed.bind(options_instance))


func on_options_closed(options_instance: Node):
	options_instance.queue_free()


func on_quit_pressed():
	get_tree().get_root().propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

