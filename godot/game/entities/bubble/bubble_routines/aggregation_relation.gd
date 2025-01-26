extends BubblesRelation
class_name Aggregation

# Configurable constants
const SCALE_INCREASE: float = 0.8  					# Scale increase for the surviving bubble

var tweenGrowing: Tween
var tweenDying: Tween


#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _init(first_bubble: Bubble, second_bubble: Bubble, bubbles_meeting_distance: float, doing_time: float) -> void:
	# Initialize the two bubbles: bubble1 is the surviving bubble, bubble2 is the disappearing bubble
	super._init(first_bubble if first_bubble.level >= second_bubble.level else second_bubble, second_bubble if first_bubble.level >= second_bubble.level else first_bubble, bubbles_meeting_distance, doing_time)
	# Ensure the surviving bubble is visually above the disappearing bubble
	if bubble1.z_index < bubble2.z_index:
		bubble1.z_index = bubble2.z_index + 1


func _start_doing() -> void:
	# Check if the two bubbles are close enough to aggregate
	if bubble1.global_position.distance_to(bubble2.global_position) > meeting_distance:
		return
	
	current_state = BubblesRelation.RelationState.DOING
	task_timer.start()

	# Increase the properties of the surviving bubble
	bubble1.level += bubble2.level
	bubble1.health += bubble2.health

	# Remove the defeated bubble
	bubble2.queue_free()

	# Visually resize the surviving bubble
	tweenGrowing = get_tree().create_tween()
	var newSize: float = bubble1.level * SCALE_INCREASE
	tweenGrowing.tween_property(bubble1, "scale", Vector2(newSize, newSize), task_waiting_time)
	tweenGrowing.play()


func _done() -> void:
	#bubble1.exit_from_routine()
	self.queue_free()


func _check_end_condition() -> bool:
	return bubble1 == null