extends Node2D

class_name Weapon

@export var damage_per_second: float = 1.0

var active: bool = false:
	set(value):
		active = value
		if active == true:
			_activate_weapon()

var firing: bool = false:
	set(value):
		firing = value

func _activate_weapon() -> void:
	print("ACTIVATE WEAPON")
	pass
