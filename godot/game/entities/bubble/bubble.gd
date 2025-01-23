extends Node2D

class_name Bubble

@export var max_health: float = 1.0
var health: float = 1.0

var pressed: bool = false

func _ready() -> void:
	health = max_health

func nearby_bubble_popped() -> void:
	pass
	

func hit_bubble(weapon: Node2D, damage: float) -> void:
	print("HIT BY: " + weapon.name + " DAMAGE: " + str(damage))
	health -= damage
	if weapon is Finger:
		pressed = true


func release_bubble(weapon: Node2D) -> void:
	print("RELEASED BY: " + weapon.name)

	health = max_health
	
	if weapon is Finger:
		pressed = false
