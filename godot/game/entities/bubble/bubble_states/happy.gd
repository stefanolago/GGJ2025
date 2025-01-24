extends BubbleHumorState


func enter() -> void:
	super()
	await get_tree().create_timer(1.0).timeout
	transition.emit("Calm")