extends BubbleHumorState


var timer_to_calm: float = 1.0

func enter() -> void:
	super()
	bubble.sprite.set_face_mood("happy")
	bubble.squishy_tween()
	GlobalAudio.play_one_shot("bubble_happy")
	bubble.nearby_popped.connect(_on_nearby_popped)
	timer_to_calm = 1.0


func exit() -> void:
	super()
	bubble.nearby_popped.disconnect(_on_nearby_popped)


func physics_update(delta: float) -> void:
	timer_to_calm -= delta
	if timer_to_calm <= 0.0:
		transition.emit("Calm")


func _on_nearby_popped(_position: Vector2) -> void:
	if bubble.corpses_seen > bubble.less_happy_limit:
		transition.emit("Worried")