extends BubbleHumorState


func enter() -> void:
	super()
	bubble.sprite.set_face_mood("scared")
	bubble.manage_panic()


func update(_delta: float) -> void:
	if bubble.corpses_seen == 0:
		transition.emit("Calm")
