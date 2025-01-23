extends State
class_name BubbleState

var bubble: Bubble

func _ready() -> void:
	await owner.ready
	bubble = owner

func enter() -> void:
	onEnter()

func exit() -> void:
	onExit()

func onEnter() -> void:
	pass

func onExit() -> void:
	pass
