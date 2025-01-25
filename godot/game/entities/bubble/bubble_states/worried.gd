extends BubbleHumorState

func enter() -> void:
	super()
	bubble.sprite.set_face_mood("worried")
	bubble.nearby_popped.connect(_on_nearby_popped)


func exit() -> void:
	super()
	print("EXIT WORRIED: " + bubble.name)
	if bubble.nearby_popped.is_connected(_on_nearby_popped):
		bubble.nearby_popped.disconnect(_on_nearby_popped)
	else:
		push_warning("bubble.nearby_popped is not connected to _on_nearby_popped")


func _on_nearby_popped(_position: Vector2) -> void:
	if bubble.corpses_seen > bubble.worried_limit:
		print("ON NEARBY POPPED WORRIED TO SCARE: " + bubble.name)
		transition.emit("Scared")