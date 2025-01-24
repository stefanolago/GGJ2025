extends BubbleHumorState


func enter() -> void:
	super()
	bubble.nearby_popped.connect(_on_nearby_popped)


func exit() -> void:
	super()
	bubble.nearby_popped.disconnect(_on_nearby_popped)



func _on_nearby_popped(_position: Vector2) -> void:
	if bubble.corpses_seen <= 2.0:
		transition.emit("Happy")
	elif bubble.corpses_seen <= 4.0:
		transition.emit("LessHappy")
	else:
		transition.emit("Worried")