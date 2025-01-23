extends BubbleState


func enter() -> void:
	print("Pressed State enter")


func exit() -> void:
	print("Pressed State exit")


func physics_update(_delta: float) -> void:
	if bubble.health <= 0:
		transition.emit("PoppingState")

	if not bubble.pressed:
		transition.emit("UntouchedState")

