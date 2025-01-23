extends Node2D

class_name Weapon

@export var damage_per_second: float = 1.0

var active: bool = false

var firing: bool = false:
	set(value):
		firing = value
		print("Firing: %s" % firing)



