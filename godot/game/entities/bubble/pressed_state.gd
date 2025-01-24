extends BubbleState


func enter() -> void:
	print("Pressed State enter")
	(bubble.sprite.material as ShaderMaterial).set_shader_parameter("frequency", 300.0)


func exit() -> void:
	print("Pressed State exit")


func physics_update(_delta: float) -> void:
	if bubble.health <= 0:
		transition.emit("PoppingState")

	if not bubble.pressed:
		transition.emit("UntouchedState")


