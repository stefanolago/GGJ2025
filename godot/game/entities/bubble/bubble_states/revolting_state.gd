extends BubbleHumorState


func enter() -> void:
	bubble.velocity = Vector2.ZERO
	bubble.sprite.set_face_mood("angry")
	
