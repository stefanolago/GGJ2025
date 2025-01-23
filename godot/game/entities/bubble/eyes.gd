extends Node2D

@export var max_pupil_distance: float = 40.0  # Max distance that the pupil can move from the origin
@onready var face_sprite: Sprite2D = %BubbleFaceSprite

var lookat_position: Vector2

func _process(_delta: float) -> void:
	if update_lookat:
		# Get the mouse position in global space
		# TODO: Delete, use lookat_position instead
		var local_mouse_pos: Vector2 = get_global_mouse_position() - self.global_position
		
		# Limit the pupil's movement within a circle of max_pupil_distance
		if local_mouse_pos.length() > max_pupil_distance:
			local_mouse_pos = local_mouse_pos.normalized() * max_pupil_distance

		# Update the pupil's position relative to the eye
		face_sprite.position = local_mouse_pos

func update_lookat(target_position: Vector2) -> void:
	lookat_position = target_position
