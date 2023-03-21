extends AudioStreamPlayer

var sounds_playing: int = 0
var max_sounds_playing: int = 50

@onready var timer: Timer = $Timer

func _ready():
	finished.connect(on_finished)
	timer.timeout.connect(on_timer_timeout)
	tree_exiting.connect(on_tree_exiting)

func on_finished():
	timer.start()
	

func on_timer_timeout():
	play()


func on_tree_exiting():
	stop()
	queue_free()
