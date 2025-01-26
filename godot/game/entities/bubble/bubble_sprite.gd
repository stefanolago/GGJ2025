extends Sprite2D

class_name BubbleSprite

@export var max_pupil_distance: float = 40.0  # Max distance that the pupil can move from the origin

@onready var face_sprite: AnimatedSprite2D = %BubbleFaceSprite
@onready var start_face_position: Vector2 = face_sprite.position

var lookat_position: Vector2
var last_mood_registered: String = "calm"
var max_distance_look_at_mouse: float = 300000


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and (event as InputEventMouseButton).pressed:
			var mouse_pos: Vector2 = get_global_mouse_position()
			var distance_squared: float = global_position.distance_squared_to(mouse_pos)
			if distance_squared <= max_distance_look_at_mouse:
				update_lookat(mouse_pos - self.global_position)
			else:
				reset_lookat()
		elif (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and not (event as InputEventMouseButton).pressed:
			reset_lookat()
	
		# Limit the eyes movement within a circle of max_pupil_distance
		
		var target: Vector2 = lookat_position
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
	
	face_sprite.play(mood)


func set_body_status(status: String) -> void:
	match status:
		"untouched":
			(texture as AnimatedTexture).current_frame = 0
		"pressed":
			(texture as AnimatedTexture).current_frame = 1
		"popped":
			(texture as AnimatedTexture).current_frame = randi_range(2, 3)
