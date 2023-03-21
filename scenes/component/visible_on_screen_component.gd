extends VisibleOnScreenNotifier2D

@export var target: Node

func _ready():
	screen_entered.connect(on_screen_entered)
	screen_exited.connect(on_screen_exited)


func on_screen_entered():
	target.visible = true


func on_screen_exited():
	target.visible = false
	
