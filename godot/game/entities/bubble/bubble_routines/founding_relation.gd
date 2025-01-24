extends BubblesRelation
class_name CityFounding


var city_scene: PackedScene = preload("res://game/entities/city.tscn")


#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _init(first_bubble: Bubble, second_bubble: Bubble, bubbles_meeting_distance: float, doing_time: float) -> void:
	super._init(first_bubble, second_bubble, bubbles_meeting_distance, doing_time)


func _start_doing() -> void:
	pass


func _done() -> void:
	city_scene.instantiate()
