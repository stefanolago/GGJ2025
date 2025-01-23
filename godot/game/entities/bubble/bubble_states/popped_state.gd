extends BubbleState


func enter() -> void:
	print("Popped State enter")
	bubble.queue_free()


func exit() -> void:
	print("Popping State exit")