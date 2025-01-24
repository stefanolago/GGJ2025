extends BubblesRelation
class_name Family


const TIME_FAMILY_WANDERING: float = 5.0   		# Time required for the family to wander
const TIME_CHILD_GROW: float = 10.0        		# Time required for the child to grow
const CHILD_PERPENDICULAR_SHIFT: float = 80.0 	# Perpendicular shift of the child

var bubble_scene: PackedScene = preload("res://game/entities/bubble/bubble.tscn")
var child: Bubble = null

var child_growing_timer: Timer
var family_wandering_timer: Timer
var family_wandering_velocity: Vector2

var child_tween: Tween


#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _init(first_bubble: Bubble, second_bubble: Bubble, bubbles_meeting_distance: float, doing_time: float) -> void:
	super._init(first_bubble, second_bubble, bubbles_meeting_distance, doing_time)
	# Initialize the timers
	child_growing_timer = _init_timer(TIME_CHILD_GROW, false, false, _grow_child)
	family_wandering_timer = _init_timer(TIME_FAMILY_WANDERING, false, false, _on_family_wandering_timeout)


func _start_doing() -> void:
	current_state = BubblesRelation.RelationState.DOING
	task_timer.start()


func _done() -> void:
	bubble1.move_and_collide(family_wandering_velocity)
	bubble2.move_and_collide(family_wandering_velocity)
	if child != null:
		child.move_and_collide(family_wandering_velocity)	



#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _on_task_timer_timeout() -> void:
	# Create a child bubble at the midpoint between the two parent bubbles
	child = bubble_scene.instantiate() as Bubble
	
	# Calculate the midpoint between the two parents
	var midpoint: Vector2 = bubble1.global_position.lerp(bubble2.global_position, 0.5)

	# Calculate the perpendicular offset vector (normalized)
	var distance_vector: Vector2 = bubble2.global_position - bubble1.global_position
	var perpendicular_offset: Vector2 = Vector2(-distance_vector.y, distance_vector.x).normalized() * CHILD_PERPENDICULAR_SHIFT

	# Position the child at the midpoint, shifted slightly downward
	child.global_position = midpoint + perpendicular_offset

	child.scale = Vector2(0.5, 0.5)
	child.is_in_routine = true

	# Ensure the child is visually above the parents
	child.z_index = max(bubble1.z_index, bubble2.z_index) + 1

	get_parent().add_child(child)
	
	_set_family_velocity()
	family_wandering_timer.start()

	# Animate the child's growth
	child_tween = get_tree().create_tween()
	child_tween.tween_property(child, "scale", Vector2(1, 1), TIME_CHILD_GROW)
	child_tween.play()

	child_growing_timer.start()
	current_state = BubblesRelation.RelationState.DONE


func _grow_child() -> void:
	family_wandering_timer.stop()
	# Assign a new routine to the child and detach it from the family
	child.assigned_routine = RoutineManager.get_random_routine()
	child.is_in_routine = false
	child.scale = Vector2(1, 1)
	child = null
	current_state = BubblesRelation.RelationState.APPROCHING



#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _on_family_wandering_timeout() -> void:
	_set_family_velocity()
	family_wandering_timer.start()


func _set_family_velocity() -> void:
	family_wandering_velocity = RoutineManager.get_walking_velocity()
	bubble1.velocity = family_wandering_velocity
	bubble2.velocity = family_wandering_velocity
	if child != null:
		child.velocity = family_wandering_velocity

