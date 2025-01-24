extends BubbleHumorState


func enter() -> void:
	super()
	bubble.sprite.set_face_mood("super_happy")
	bubble.nearby_popped.connect(_on_nearby_popped)
	await get_tree().create_timer(1.0).timeout
	transition.emit("Calm")


func exit() -> void:
	super()
	bubble.nearby_popped.disconnect(_on_nearby_popped)


func _on_nearby_popped(_position: Vector2) -> void:
	if bubble.corpses_seen <= bubble.happy_limit:
		pass
	elif bubble.corpses_seen <= bubble.less_happy_limit:
		transition.emit("LessHappy")
	else:
		transition.emit("Worried")