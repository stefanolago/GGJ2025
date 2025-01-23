extends Node

class_name State

@warning_ignore("unused_signal")
signal transition(new_state_name: StringName)

func enter() -> void:
	print("%s enter" % self.name)

func exit() -> void:
	print("%s exit" % self.name)

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
