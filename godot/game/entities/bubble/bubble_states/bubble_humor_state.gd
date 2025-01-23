extends BubbleState
class_name BubbleHumorState


@export var state_color: Color
@export var corpses_limit: int


func on_enter() -> void:
	bubble.change_color(state_color)
