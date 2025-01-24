extends State
class_name BubbleState

var bubble: Bubble

func _ready() -> void:
	await owner.ready
	bubble = owner

func enter() -> void:
	on_enter()

func exit() -> void:
	on_exit()

func on_enter() -> void:
	pass

func on_exit() -> void:
	pass
