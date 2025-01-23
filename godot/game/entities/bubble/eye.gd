extends Node2D
class_name Eye

@onready var pupil: Node2D = %Pupil


func update_pupil(mouse_global_pos: Vector2, max_pupil_distance: float) -> void:
	# Convert the mouse position to the local space of the eye
	var local_mouse_pos: Vector2 = mouse_global_pos - self.global_position

	# Limit the pupil's movement within a circle of max_pupil_distance
	if local_mouse_pos.length() > max_pupil_distance:
		local_mouse_pos = local_mouse_pos.normalized() * max_pupil_distance

	# Update the pupil's position relative to the eye
	pupil.position = local_mouse_pos
