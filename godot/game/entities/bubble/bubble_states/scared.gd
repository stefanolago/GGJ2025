extends BubbleHumorState


func enter() -> void:
	super()
	bubble.sprite.set_face_mood("scared")
	# start an animation to detach itself from the bubblewrap?
	# have to insert a delay since the previous state needs
	# to finish disconnecting its signals
	await get_tree().create_timer(0.2).timeout
	transition.emit("RunningAway")
