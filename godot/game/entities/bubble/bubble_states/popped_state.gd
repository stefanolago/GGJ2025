extends BubbleState


func enter() -> void:
	bubble.sprite.set_body_status("popped")
	bubble.pop()


func exit() -> void:
	pass