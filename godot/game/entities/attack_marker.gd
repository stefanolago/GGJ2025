extends Node2D
class_name AttackMarker

@export var sprite: Sprite2D
@export var camera: Camera2D
@export var alert_margin: Vector2 = Vector2(10, 10)
@export var fade_duration: float = 1.8				# Time for fade in/out
@export var initial_alpha: float = 0.0 				# Initial alpha value (1.0 = fully opaque)

@onready var visible_on_screen_notifier: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

var last_damage_position: Vector2
var screen_size: Vector2
var tween: Tween


func _ready() -> void:
	sprite.hide()
	if camera == null:
		camera = get_viewport().get_camera_2d()
	screen_size = get_viewport_rect().size / camera.zoom
	sprite.modulate.a = initial_alpha



func _physics_process(_delta: float) -> void:
	if not sprite.visible:
		return
	if visible_on_screen_notifier.is_on_screen():
		_reset()
		return
	_set_marker(last_damage_position)


func show_attack_hint(damage_position: Vector2) -> void:
	if visible_on_screen_notifier.is_on_screen():
		sprite.hide()
		return
	last_damage_position = damage_position
	sprite.reparent(camera)
	# get_parent().remove_child(sprite)
	# camera.add_child(sprite)
	sprite.show()
	_fade_in()



func _set_marker(damage_position: Vector2) -> void:
	var screen_center: Vector2 = camera.global_position

	# Calculate the position of the screen edges with a margin
	var half_size: Vector2 = screen_size / 2 - alert_margin
	var min_x: float = screen_center.x - half_size.x
	var max_x: float = screen_center.x + half_size.x
	var min_y: float = screen_center.y - half_size.y
	var max_y: float = screen_center.y + half_size.y

	# Define the four screen edges as segments
	var edges: Array = [
		[Vector2(min_x, min_y), Vector2(max_x, min_y)],  # Top edge
		[Vector2(min_x, min_y), Vector2(min_x, max_y)],  # Left edge
		[Vector2(max_x, min_y), Vector2(max_x, max_y)],  # Right edge
		[Vector2(min_x, max_y), Vector2(max_x, max_y)]   # Bottom edge
	]

	# Check intersections with the screen edges
	for edge: Array in edges:
		var intersection = Geometry2D.segment_intersects_segment(screen_center, damage_position, edge[0], edge[1])
		if intersection:
			sprite.global_position = intersection
			return  # Exit early once the intersection is found


func _reset() -> void:
	# camera.get_parent().remove_child(sprite)
	# self.add_child(sprite)
	sprite.reparent(self)
	sprite.position = Vector2.ZERO
	tween.stop()
	sprite.hide()

# Fade in and out functions
func _fade_in() -> void: _fade(false, Tween.EASE_OUT, Tween.TRANS_QUINT)
func _fade_out() -> void: _fade(true, Tween.EASE_IN, Tween.TRANS_QUINT)

# Core fade function
func _fade(is_fade_out: bool, ease_id: int, trans_id: int) -> void:
	tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0 if is_fade_out else 1.0, fade_duration).set_ease(ease_id).set_trans(trans_id)
	tween.play()
	await tween.finished
	if is_fade_out:
		hide()
	else:
		_fade_out()
