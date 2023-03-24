extends Camera2D

@export_category("Overview Settings")
@export var overview_camera: bool = false
@export var key = true
@export var drag = true
@export var edge = true
@export var wheel = true
@export var camera_speed = 1600
@export var camera_margin = Vector2(1200, 800)

const ZOOM_SPEED = 0.25

var original_zoom
var camera_zoom
var max_zoom_out
var max_zoom_in
var camera_movement: Vector2
var _prev_mouse_pos = null

var __rmbk = false
var __keys = [false, false, false, false]

@export_category("Camera settings")
@export var current: bool = true
@export var smoothing_factor: int = 20

@onready var target_position = global_position

@onready var sync = get_parent().get_node("Sync")

var initial_position

func _ready():
	if overview_camera:
		set_drag_horizontal_enabled(false)
		set_drag_vertical_enabled(false)
	
	original_zoom = get_zoom() * 0.5
	camera_zoom = original_zoom
	max_zoom_out = original_zoom
	max_zoom_in = max_zoom_out * 8
	initial_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if sync == null:
		sync = get_parent().get_node("Sync")
		
	if current:
		if not is_current():
			make_current()
		if not overview_camera:
			acquire_target()
			
	if overview_camera:
		
		if key and sync.connected:
			if __keys[0]:
				camera_movement.x -= camera_speed * delta
			if __keys[1]:
				camera_movement.y -= camera_speed * delta
			if __keys[2]:
				camera_movement.x += camera_speed * delta
			if __keys[3]:
				camera_movement.y += camera_speed * delta
		
		if edge:
			var rec = get_viewport().get_visible_rect()
			var v = get_local_mouse_position() + rec.size/2
			if rec.size.x - v.x <= camera_margin.x:
				camera_movement.x += camera_speed * delta
			if v.x <= camera_margin.x:
				camera_movement.x -= camera_speed * delta
			if rec.size.y - v.y <= camera_margin.y:
				camera_movement.y += camera_speed * delta
			if v.y <= camera_margin.y:
				camera_movement.y -= camera_speed * delta
			
		if drag and __rmbk:
			camera_movement = (_prev_mouse_pos - get_local_mouse_position()) * 2
			
		target_position += camera_movement * get_zoom()
			
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * smoothing_factor))
	
	if overview_camera:
		camera_movement = Vector2(0,0)
		_prev_mouse_pos = get_local_mouse_position()
		


func _unhandled_input(event):
	if overview_camera:
		if event is InputEventMouseButton:
			if drag and\
				event.button_index == MOUSE_BUTTON_RIGHT:
				# Control by right mouse button.
				if event.pressed: __rmbk = true
				else: __rmbk = false
			# Check if mouse wheel was used. Not handled by ImputMap!
			if wheel:
				# Checking if future zoom won't be under 0.
				# In that cause engine will flip screen.
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and\
				camera_zoom.x - original_zoom.x * ZOOM_SPEED > max_zoom_out.x and\
				camera_zoom.y - original_zoom.y * ZOOM_SPEED > max_zoom_out.x:
					camera_zoom -= original_zoom * ZOOM_SPEED
					set_zoom(camera_zoom)
					# Checking if future zoom won't be above zoom_out_limit.
				if event.button_index == MOUSE_BUTTON_WHEEL_UP and\
				camera_zoom.x + original_zoom.x * ZOOM_SPEED < max_zoom_in.x and\
				camera_zoom.y + original_zoom.y * ZOOM_SPEED < max_zoom_in.y:
					camera_zoom += original_zoom * ZOOM_SPEED
					set_zoom(camera_zoom)
					
		if event is InputEventKey:
			if event.is_action_pressed("reset_camera"):
				target_position = initial_position
			
			# Control by keyboard handled by InpuMap.
			if event.is_action_pressed("ui_left"):
				__keys[0] = true
			if event.is_action_pressed("ui_up"):
				__keys[1] = true
			if event.is_action_pressed("ui_right"):
				__keys[2] = true
			if event.is_action_pressed("ui_down"):
				__keys[3] = true
			if event.is_action_released("ui_left"):
				__keys[0] = false
			if event.is_action_released("ui_up"):
				__keys[1] = false
			if event.is_action_released("ui_right"):
				__keys[2] = false
			if event.is_action_released("ui_down"):
				__keys[3] = false



func acquire_target():
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player = player_nodes[0] as Node2D
		target_position = player.global_position
