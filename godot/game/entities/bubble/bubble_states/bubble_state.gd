extends State
class_name BubbleState

var bubble: Bubble

func _ready() -> void:
	await owner.ready
	bubble = owner

func enter() -> void:
	print("%s enter" % self.name)
	onEnter()

func exit() -> void:
	print("%s exit" % self.name)
	onExit()

func onEnter() -> void:
	pass

func onExit() -> void:
	pass
