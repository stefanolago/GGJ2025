extends BubbleState


func enter() -> void:
	await get_tree().create_timer(0.1).timeout
	transition.emit("PoppedState")


func exit() -> void:
	pass
