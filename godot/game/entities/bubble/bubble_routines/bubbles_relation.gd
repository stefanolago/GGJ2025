extends Node
class_name BubblesRelation

# Configurable constants
const APPROCHING_SPEED: float = 200.0      			# Speed to approach the child
const DEFAULT_MEETING_DISTANCE: float = 200.0      	# Default distance for bubbles to meet
const DEFAULT_DOING_WAITING_TIME: float = 5.0      	# Default waiting time for the routine
const DEBUGGING_COLOR: bool = false

const COLOR_DEBUGGING: bool = false					# Flag to enable color debugging


var bubble1: Bubble
var bubble2: Bubble
var direction1: Vector2
var direction2: Vector2
var meeting_distance: float = DEFAULT_MEETING_DISTANCE
var task_waiting_time: float = DEFAULT_DOING_WAITING_TIME
var task_timer: Timer

enum RelationState {
	APPROCHING,
	DOING,
	DONE
}
var current_state: RelationState = RelationState.APPROCHING: set = _set_relation_state

func _set_relation_state(value: RelationState) -> void:
	current_state = value
	if DEBUGGING_COLOR:
		match current_state:
			BubblesRelation.RelationState.APPROCHING:
				_set_bubble_color(Color(1.0, 0.0, 0.0))
			BubblesRelation.RelationState.DOING:
				_set_bubble_color(Color(0.0, 1.0, 0.0))
			BubblesRelation.RelationState.DONE:
				_set_bubble_color(Color(0.0, 0.0, 1.0))




#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _init(first_bubble: Bubble, second_bubble: Bubble, bubbles_meeting_distance: float, doing_time: float) -> void:
	bubble1 = first_bubble
	bubble2 = second_bubble
	# first_bubble.is_in_routine = true
	# second_bubble.is_in_routine = true

	_set_relation_param(bubbles_meeting_distance, doing_time)


func _process(_delta: float) -> void:
	if _check_end_condition():
		_end_relation()
		return
	match current_state:
		BubblesRelation.RelationState.APPROCHING:
			if not _are_bubbles_distant(meeting_distance):
				_start_doing()
			else:
				_approch_bubbles()
			
		BubblesRelation.RelationState.DOING:
			# TODO check se son morti e stoppa il timer
			pass

		BubblesRelation.RelationState.DONE:
			_done()


func _set_relation_param(bubbles_meeting_distance: float, doing_time: float) -> void:
	meeting_distance = bubbles_meeting_distance
	task_waiting_time = doing_time
	task_timer = _init_timer(task_waiting_time, false, true, _on_task_timer_timeout)


func _start_doing() -> void:
	pass


func _done() -> void:
	pass


func _check_end_condition() -> bool:
	return false


func _end_relation() -> void:
	# if bubble1 != null:
	# 	bubble1.is_in_routine = false
	# if bubble2 != null:
	# 	bubble2.is_in_routine = false
	self.queue_free()



#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _approch_bubbles() -> void:
	if bubble1 == null or bubble2 == null:
		return
	direction1 = (bubble2.global_position - bubble1.global_position).normalized()
	direction2 = (bubble1.global_position - bubble2.global_position).normalized()
	bubble1.velocity = direction1 * APPROCHING_SPEED
	bubble2.velocity = direction2 * APPROCHING_SPEED


	if bubble1 != null:
		bubble1.move_and_slide()
	if bubble2 != null:
		bubble2.move_and_slide()


func _are_bubbles_distant(distance: float) -> bool:
	return bubble1.global_position.distance_to(bubble2.global_position) > distance


func _set_bubble_color(color: Color) -> void:
	if bubble1 != null:
		bubble1.change_color(color)
	if bubble2 != null:
		bubble2.change_color(color)


func _init_timer(wait_time: float, autostart: bool, one_shot: bool, callback: Callable) -> Timer:
	var timer: Timer = Timer.new()
	timer.wait_time = wait_time
	timer.autostart = autostart
	timer.one_shot = one_shot 
	add_child(timer)
	timer.timeout.connect(callback)
	return timer


func _on_task_timer_timeout() -> void:
	current_state = BubblesRelation.RelationState.DONE
