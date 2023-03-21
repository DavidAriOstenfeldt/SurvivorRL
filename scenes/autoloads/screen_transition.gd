extends CanvasLayer

signal transitioned_halfway()


func play_transition():
	$AnimationPlayer.play("default")


func change_scene(scene):
	if scene is PackedScene:
		get_tree().change_scene_to_packed(scene)
	elif scene is String:
		get_tree().change_scene_to_file(scene)


func emit_transitoned_halfway():
	transitioned_halfway.emit()
