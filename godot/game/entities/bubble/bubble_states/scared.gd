extends BubbleHumorState


func on_enter() -> void:
	super.on_enter()
	bubble.detach()

func update(_delta: float) -> void:
	pass
