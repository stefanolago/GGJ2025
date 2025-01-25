extends BubbleState


func enter() -> void:
	bubble.sprite.set_body_status("popped")
	bubble.pop()
	bubble.body_anim_player.play("Idle")


func exit() -> void:
	pass
