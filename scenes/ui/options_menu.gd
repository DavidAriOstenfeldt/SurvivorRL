extends CanvasLayer

signal back_pressed

@onready var window_button: Button = $%WindowButton
@onready var damage_number_button: Button = %DamageNumbersButton
@onready var sfx_slider = %SfxSlider
@onready var music_slider = %MusicSlider
@onready var back_button = %BackButton
@onready var delete_save_button = %DeleteSaveButton



func _ready():
	back_button.pressed.connect(on_back_pressed)
	window_button.pressed.connect(on_window_button_pressed)
	damage_number_button.pressed.connect(on_damage_number_button_pressed)
	sfx_slider.value_changed.connect(on_audio_slider_changed.bind("sfx"))
	music_slider.value_changed.connect(on_audio_slider_changed.bind("music"))
	
	update_display()
	

func update_display():
	window_button.text = "Windowed"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_button.text = "Fullscreen"
	
	sfx_slider.value = get_bus_volume_percent("sfx")
	music_slider.value = get_bus_volume_percent("music")
	
	MetaProgression.save_data["sound_volume"] = sfx_slider.value
	MetaProgression.save_data["music_volume"] = music_slider.value
	
	damage_number_button.text = "Enabled"
	if MetaProgression.save_data["damage_numbers"] == false:
		damage_number_button.text = "Disabled"
	
	
func get_bus_volume_percent(bus_name: String):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)


func set_bus_volume_percent(bus_name: String, percent):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func on_window_button_pressed():
	var mode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		MetaProgression.save_data["windowed"] = false
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		MetaProgression.save_data["windowed"] = true
		
	update_display()


func on_damage_number_button_pressed():
	MetaProgression.save_data["damage_numbers"] = !MetaProgression.save_data["damage_numbers"]
	update_display()


func on_audio_slider_changed(value: float, bus_name: String):
	set_bus_volume_percent(bus_name, value)
	


func on_back_pressed():
	MetaProgression.save()
	ScreenTransition.play_transition()
	await ScreenTransition.transitioned_halfway
	back_pressed.emit()
