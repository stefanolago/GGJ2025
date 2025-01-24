extends TwoBubblesConnection
class_name Family

const APPROCHING_DISTANCE: float = 250.0       		# Minimum distance between the two partners
const TIME_TO_FORM_CHILD: float = 5.0      		# Time required to form a child
const TIME_FAMILY_WANDERING: float = 5.0   		# Time required for the family to wander
const TIME_CHILD_GROW: float = 10.0        		# Time required for the child to grow
const CHILD_PERPENDICULAR_SHIFT: float = 80.0 	# Perpendicular shift of the child

var bubble_scene: PackedScene = preload("res://game/entities/bubble/bubble.tscn")
var child: Bubble = null

var procreation_timer: Timer
var child_growing_timer: Timer
var family_wandering_timer: Timer
var family_wandering_velocity: Vector2

var child_tween: Tween

var current_state: FamilyState
enum FamilyState {
	DISTANT_PARENTS,
	PROCREATING,
	FAMILY_WITH_CHILD
}


#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _init(first_bubble: Bubble, second_bubble: Bubble) -> void:
	# Initialize the family with two bubbles
	bubble1 = first_bubble
	bubble2 = second_bubble
	first_bubble.is_in_routine = true
	second_bubble.is_in_routine = true
	current_state = FamilyState.DISTANT_PARENTS
	_set_parent_color(Color(1.0, 0.0, 0.0))

	# Initialize the timers
	procreation_timer = _init_timer(TIME_TO_FORM_CHILD, false, true, _create_child)
	child_growing_timer = _init_timer(TIME_CHILD_GROW, false, false, _grow_child)
	family_wandering_timer = _init_timer(TIME_FAMILY_WANDERING, false, false, _on_family_wandering_timeout)
	


func _process(_delta: float) -> void:
	match current_state:
		FamilyState.DISTANT_PARENTS:
			if not _are_bubbles_distant(APPROCHING_DISTANCE):
				_start_procreation()
				_set_parent_color(Color(160, 80, 0))
			else:
				var direction1: Vector2 = (bubble2.global_position - bubble1.global_position).normalized()
				var direction2: Vector2 = (bubble1.global_position - bubble2.global_position).normalized()
				bubble1.velocity = direction1 * APPROCHING_SPEED
				bubble2.velocity = direction2 * APPROCHING_SPEED
				bubble1.move_and_slide()
				bubble2.move_and_slide()
			
		FamilyState.PROCREATING:
			# TODO check se son morti i genitori e stoppa il timer
			pass

		FamilyState.FAMILY_WITH_CHILD:
			bubble1.move_and_collide(family_wandering_velocity)
			bubble2.move_and_collide(family_wandering_velocity)
			if child != null:
				child.move_and_collide(family_wandering_velocity)			



#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _start_procreation() -> void:
	current_state = FamilyState.PROCREATING
	procreation_timer.start()
	

func _create_child() -> void:
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
	_set_parent_color(Color(95, 133, 117))
	current_state = FamilyState.FAMILY_WITH_CHILD


func _grow_child() -> void:
	family_wandering_timer.stop()
	# Assign a new routine to the child and detach it from the family
	child.assigned_routine = RoutineManager.get_random_routine()
	child.is_in_routine = false
	child.scale = Vector2(1, 1)
	child = null
	current_state = FamilyState.DISTANT_PARENTS



#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _on_family_wandering_timeout() -> void:
	_set_family_velocity()
	family_wandering_timer.start()


func _set_family_velocity() -> void:
	family_wandering_velocity = RoutineManager.get_walking_velocity()
	print("VELOCIT°" + str(family_wandering_velocity))
	bubble1.velocity = family_wandering_velocity
	bubble2.velocity = family_wandering_velocity
	if child != null:
		child.velocity = family_wandering_velocity


func _set_parent_color(color: Color) -> void:
	bubble1.change_color(color)
	bubble2.change_color(color)
