extends BubbleHumorState


func enter() -> void:
	super()
	bubble.sprite.set_face_mood("scared")
	# start an animation to detach itself from the bubblewrap?
	# have to insert a delay since the previous state needs
	# to finish disconnecting its signals
	# create a tween that makes the bubble wobble
	# by changing the scale horizontally and vertically
	var tween: Tween = get_tree().create_tween()

	tween.tween_property(bubble, "scale", Vector2(1.1, 0.9), 0.1)
	tween.tween_property(bubble, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(bubble, "scale", Vector2(0.9, 1.1), 0.1)
	tween.tween_property(bubble, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(bubble, "scale", Vector2(1.1, 0.9), 0.1)
	tween.tween_property(bubble, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(bubble, "scale", Vector2(0.9, 1.1), 0.1)
	tween.tween_property(bubble, "scale", Vector2(1.0, 1.0), 0.1)
	await tween.finished


	transition.emit("RunningAway")
