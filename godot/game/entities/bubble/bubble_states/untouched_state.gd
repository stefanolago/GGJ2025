extends BubbleState


func enter() -> void:
	bubble.sprite.set_body_status("untouched")
	pass


func exit() -> void:
	pass


func physics_update(_delta: float) -> void:
	if bubble.pressed:
		transition.emit("PressedState")
	if bubble.health <= 0:
		transition.emit("PoppingState")


