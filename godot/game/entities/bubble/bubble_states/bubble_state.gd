extends State
class_name BubbleState

var bubble: Bubble


func _ready() -> void:
	await owner.ready
	bubble = owner
