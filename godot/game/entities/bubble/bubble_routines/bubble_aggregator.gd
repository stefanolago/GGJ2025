extends TwoBubblesConnection
class_name BubbleAggregator

# Configurable constants
const AGGREGATION_DISTANCE: float = 20.0      	 	# Minimum distance for bubbles to aggregate
const AGGREGATION_TIME: float = 3.0      			# Time required for the aggregation
const SCALE_INCREASE: float = 0.8  					# Scale increase for the surviving bubble

var tweenGrowing: Tween
var tweenDying: Tween

var current_state: AggregationState
enum AggregationState {
	DISTANT_BUBBLES,
	AGGREGATING,
	AGGREGATED
}

var aggregating_timer: Timer


#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _init(first_bubble: Bubble, second_bubble: Bubble) -> void:
	# Initialize the two bubbles: bubble1 is the surviving bubble, bubble2 is the disappearing bubble
	if first_bubble.level >= second_bubble.level:
		bubble1 = first_bubble
		bubble2 = second_bubble
	else:
		bubble1 = second_bubble
		bubble2 = first_bubble
	if bubble1.z_index < bubble2.z_index:
		bubble1.z_index = bubble2.z_index + 1
	first_bubble.is_in_routine = true
	second_bubble.is_in_routine = true
	current_state = AggregationState.DISTANT_BUBBLES
	aggregating_timer = _init_timer(AGGREGATION_TIME, false, true, _on_aggregating_timer_timeout)



func _process(_delta: float) -> void:
	match current_state:
		AggregationState.DISTANT_BUBBLES:
			if not _are_bubbles_distant(AGGREGATION_DISTANCE):
				_start_aggregation()
			else:
				var direction1: Vector2 = (bubble2.global_position - bubble1.global_position).normalized()
				var direction2: Vector2 = (bubble1.global_position - bubble2.global_position).normalized()
				bubble1.velocity = direction1 * APPROCHING_SPEED
				bubble2.velocity = direction2 * APPROCHING_SPEED
				bubble1.move_and_slide()
				bubble2.move_and_slide()
			

		AggregationState.AGGREGATING:
			# TODO check se son morti e stoppa il timer
			pass

		AggregationState.AGGREGATED:
			bubble1.exit_from_routine()
			self.queue_free()



# Method to start the aggregation between two bubbles
func _start_aggregation() -> void:
	# Check if the two bubbles are close enough to aggregate
	if bubble1.global_position.distance_to(bubble2.global_position) > AGGREGATION_DISTANCE:
		return
	
	current_state = AggregationState.AGGREGATING
	aggregating_timer.start()

	# Increase the properties of the surviving bubble
	bubble1.level += bubble2.level
	bubble1.health += bubble2.health

	# Visually resize the surviving bubble
	tweenGrowing = get_tree().create_tween()
	var newSize: float = bubble1.level * SCALE_INCREASE
	tweenGrowing.tween_property(bubble1, "scale", Vector2(newSize, newSize), AGGREGATION_TIME)
	tweenGrowing.play()

	# Remove the defeated bubble
	bubble2.queue_free()


func _on_aggregating_timer_timeout() -> void:
	current_state = AggregationState.AGGREGATED
