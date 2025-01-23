extends BubbleState

func update(_delta: float) -> void:
	if bubble.corpses_seen > 0:
		bubble.change_state("LessHappy")
