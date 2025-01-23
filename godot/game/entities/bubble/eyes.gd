extends Node2D

@export var max_pupil_distance: float = 40.0  # Max distance that the pupil can move from the origin
@onready var left_eye: Eye = %EyeLeft
@onready var right_eye: Eye = %EyeRight



func _process(_delta: float) -> void:
	# Get the mouse position in global space
	var mouse_global_pos: Vector2 = get_global_mouse_position()

	# Update the position of the pupils
	left_eye.update_pupil(mouse_global_pos, max_pupil_distance)
	right_eye.update_pupil(mouse_global_pos, max_pupil_distance)
