extends BubbleHumorState

func enter() -> void:
	super()
	bubble.sprite.set_face_mood("worried")
	bubble.squishy_tween()
	(bubble.sprite.material as ShaderMaterial).set_shader_parameter("amplitude", 15.0)
	(bubble.sprite.material as ShaderMaterial).set_shader_parameter("frequency", 25.0)

	GlobalAudio.play_one_shot("bubble_worried")
	bubble.nearby_popped.connect(_on_nearby_popped)


func exit() -> void:
	super()
	(bubble.sprite.material as ShaderMaterial).set_shader_parameter("frequency", 0.0)
	if bubble.nearby_popped.is_connected(_on_nearby_popped):
		bubble.nearby_popped.disconnect(_on_nearby_popped)
	else:
		push_warning("bubble.nearby_popped is not connected to _on_nearby_popped")


func _on_nearby_popped(_position: Vector2) -> void:
	if bubble.corpses_seen > bubble.worried_limit:
		transition.emit("Scared")