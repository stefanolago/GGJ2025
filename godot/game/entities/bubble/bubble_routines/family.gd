extends Node

const FAMILY_DISTANCE: float = 50.0         # Minimum distance between the two partners
const TIME_TO_FORM_CHILD: float = 10.0      # Time required to form a child
const CHILD_GROW_TIME: float = 10.0         # Time required for the child to grow

var bubble1: Bubble
var bubble2: Bubble
var timer: float = 0.0
var child_timer: float = 0.0
var child: Bubble = null



func _init(bubble1: CharacterBody2D, bubble2: CharacterBody2D) -> void:
	# Initialize the family with two bubbles
	self.bubble1 = bubble1
	self.bubble2 = bubble2
	bubble1.is_in_family = true
	bubble2.is_in_family = true


func _process(delta: float) -> void:
	if bubble1.global_position.distance_to(bubble2.global_position) > FAMILY_DISTANCE:
		# If the bubbles are too far, make them move closer
		var direction1 = (bubble2.global_position - bubble1.global_position).normalized()
		var direction2 = (bubble1.global_position - bubble2.global_position).normalized()
		bubble1.velocity = direction1 * 100
		bubble2.velocity = direction2 * 100
		bubble1.move_and_slide()
		bubble2.move_and_slide()
	else:
		# Increment the timer when they are close enough
		timer += delta
		if timer >= TIME_TO_FORM_CHILD and child == null:
			child = create_child()
			child_timer = 0.0
			timer = 0.0
		elif child != null:
			# Manage the child's growth
			child_timer += delta
			if child_timer >= CHILD_GROW_TIME:
				grow_child()




func create_child() -> Bubble:
	# Create a child bubble at the midpoint between the two parent bubbles
	var child_instance: Bubble = Bubble.new()
	child_instance.global_position = bubble1.global_position.linear_interpolate(bubble2.global_position, 0.5)
	get_parent().add_child(child_instance)
	return child_instance


func grow_child() -> void:
	# Assign a new routine to the child and detach it from the family
	child.assigned_routine = BubbleRoutine.values()[randi() % BubbleRoutine.size()]
	child.is_in_family = false
	child = null
