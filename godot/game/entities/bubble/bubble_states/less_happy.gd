extends BubbleHumorState

func update(_delta: float) -> void:
	if bubble.corpses_seen > corpses_limit:
		transition.emit("Worried")
