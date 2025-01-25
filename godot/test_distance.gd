extends Node2D

@onready var bubble1: Bubble = $Bubble
@onready var bubble2: Bubble = $Bubble2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(bubble1.global_position.distance_squared_to(bubble2.global_position))
