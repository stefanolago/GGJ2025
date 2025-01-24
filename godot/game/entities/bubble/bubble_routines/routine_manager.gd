extends Node


# Bubble routines
enum BubbleRoutine {
	NONE,
	ATTACK_WALL,
	GROUP_UP,
	FAMILY_BUILDING,
	COMMUNITY_BUILDING
}


func _ready() -> void:
	# Assign initial routines to all bubbles
	assign_routines()

func _process(delta: float) -> void:
	# Check for bubbles that can form families
	check_for_families()



func assign_routines() -> void:
	# Assign random routines to all bubbles
	var bubbles = get_tree().get_nodes_in_group("bubbles")
	for bubble in bubbles:
		if bubble.assigned_routine == BubbleRoutine.NONE:
			bubble.assigned_routine = BubbleRoutine.values()[randi() % BubbleRoutine.size()]


func check_for_families() -> void:
	# Check if two bubbles can form a family
	var bubbles = get_tree().get_nodes_in_group("bubbles")
	for bubble in bubbles:
		if bubble.is_available_for_family():
			for other_bubble in bubbles:
				if other_bubble != bubble and other_bubble.is_available_for_family():
					if bubble.global_position.distance_to(other_bubble.global_position) <= 50.0:
						form_family(bubble, other_bubble)


func form_family(bubble1: CharacterBody2D, bubble2: CharacterBody2D) -> void:
	# Create a family with two bubbles
	var family = Family.new(bubble1, bubble2)
	add_child(family)
