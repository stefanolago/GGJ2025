extends Node
class_name TwoBubblesConnection

# Configurable constants
const APPROCHING_SPEED: float = 200.0      			# Speed to approach the child

var bubble1: Bubble
var bubble2: Bubble


#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _are_bubbles_distant(distance: float) -> bool:
	return bubble1.global_position.distance_to(bubble2.global_position) > distance


func _init_timer(wait_time: float, autostart: bool, one_shot: bool, callback: Callable) -> Timer:
	var timer: Timer = Timer.new()
	timer.wait_time = wait_time
	timer.autostart = autostart
	timer.one_shot = one_shot 
	add_child(timer)
	timer.timeout.connect(callback)
	return timer