extends BubbleState


func enter() -> void:
	print("Popping State enter")
	await get_tree().create_timer(0.1).timeout
	transition.emit("PoppedState")


func exit() -> void:
	print("Popping State exit")
