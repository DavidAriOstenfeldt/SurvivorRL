extends Node

@onready var timer = $Timer
@onready var main = get_parent()

func _ready():
	timer.timeout.connect(on_timout)


func on_timout():
	if Engine.get_frames_per_second() < 60:
		disable_collisions(.2)
		collect_experience(.2)
	elif Engine.get_frames_per_second() < 70:
		disable_collisions(.1)
		collect_experience(.1)
	elif Engine.get_frames_per_second() < 80:
		disable_collisions(.05)
		collect_experience(.05)
	
	timer.start()


func disable_collisions(amount: float = .2):
#	print("Reducing enemy collisions by ", amount * 100, "%")
	main.call_group("enemy", "disable_collision", amount)
	

func collect_experience(amount: float = .2):
	get_tree().call_group("experience_vial", "performance_collect", amount)


