extends Sprite2D

class_name BubbleSprite

@export var max_pupil_distance: float = 40.0  # Max distance that the pupil can move from the origin

@onready var face_sprite: AnimatedSprite2D = %BubbleFaceSprite
@onready var start_face_position: Vector2 = face_sprite.position

var lookat_position: Vector2
var last_mood_registered: String = "calm"

func _process(_delta: float) -> void:
	var target: Vector2 = lookat_position
	# Get the mouse position in global space if it's held
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target= get_global_mouse_position() - self.global_position
	
	# Limit the eyes movement within a circle of max_pupil_distance
	if target.length() > max_pupil_distance:
		target = target.normalized() * max_pupil_distance

	# Update the face position relative to the bubble
	face_sprite.position = target

func reset_lookat() -> void:
	lookat_position = start_face_position

func update_lookat(target_position: Vector2) -> void:
	lookat_position = target_position


func set_face_mood(mood: String) -> void:
	if mood == "previous_mood":
		mood = last_mood_registered

	if mood != "pressed":
		last_mood_registered = mood 
	
	if mood == "attack":
		print("FACE SPRITE PLAY: " + mood)
	face_sprite.play(mood)


func set_body_status(status: String) -> void:
	match status:
		"untouched":
			(texture as AnimatedTexture).current_frame = 0
		"pressed":
			(texture as AnimatedTexture).current_frame = 1
		"popped":
			(texture as AnimatedTexture).current_frame = randi_range(2, 3)
