extends BubbleState


func enter() -> void:
	printerr("Pressed State enter")
	print(bubble.sprite.name)
	(bubble.sprite.material as ShaderMaterial).set_shader_parameter("frequency", 300.0)
	


func exit() -> void:
	printerr("Pressed State exit")


func physics_update(_delta: float) -> void:
	if bubble.health <= 0:
		transition.emit("PoppingState")

	if not bubble.pressed:
		transition.emit("UntouchedState")
