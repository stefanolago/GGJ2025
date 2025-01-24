extends BubbleHumorState


func enter() -> void:
	super()
	bubble.sprite.set_face_mood("scared")
	bubble.detach()


func update(_delta: float) -> void:
	pass
