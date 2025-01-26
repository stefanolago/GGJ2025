extends Node2D

class_name bubble_sprite

@export var max_pupil_distance: float = 40.0  # Max distance that the pupil can move from the origin

@onready var face_sprite: AnimatedSprite2D = %BubbleFaceSprite
@onready var start_face_position: Vector2 = face_sprite.position

var lookat_position: Vector2

func _physics_process(_delta: float) -> void:
	var target: Vector2 = lookat_position
	# Get the mouse position in global space if it's held
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target= get_global_mouse_position() - self.global_position
	
	# Limit the eyes movement within a circle of max_pupil_distance
	if target.length() > max_pupil_distance:
		target = target.normalized() * max_pupil_distance

	# Update the face position relative to the bubble
	print("EYES PROCESSED")
	face_sprite.position = target





func reset_lookat() -> void:
	lookat_position = start_face_position

func update_lookat(target_position: Vector2) -> void:
	lookat_position = target_position
