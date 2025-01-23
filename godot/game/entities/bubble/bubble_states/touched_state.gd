extends BubbleState


func enter() -> void:
	print("Untouched State enter")


func exit() -> void:
	print("Untouched State exit")


func physics_update(_delta: float) -> void:
	if bubble.pressed:
		transition.emit("PressedState")


