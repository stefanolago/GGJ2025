extends Node


var roaming_speed_min: float = 3.0											# Min speed of the bubble when roaming
var roaming_speed_max: float = 6.0											# Max speed of the bubble when roaming
var walking_speed: float = 2.00												# Speed of the bubble when walking
var families: Array = [] 													# Array to store families

# Bubble routines
enum BubbleRoutine {
	NONE,
	ATTACK_WALL,
	GROUP_UP,
	FAMILY_BUILDING,
	COMMUNITY_BUILDING
}


# Returns a random routine
func get_random_routine() -> BubbleRoutine:
	#return BubbleRoutine.values()[randi() % BubbleRoutine.size()]
	return BubbleRoutine.GROUP_UP


func get_roaming_velocity() -> Vector2:
	return _get_random_velocity(randf_range(roaming_speed_min, roaming_speed_max))

func get_walking_velocity() -> Vector2:
	return _get_random_velocity(walking_speed)

func _get_random_velocity(speed: float) -> Vector2:
	return Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized() * speed


func form_family(bubble1: Bubble, bubble2: Bubble) -> void:
	# Create a family with two bubbles
	if bubble1.is_in_routine or bubble2.is_in_routine:
		return
	var family: Family = Family.new(bubble1, bubble2)
	add_child(family)
	families.append(family)


func aggregate(bubble1: Bubble, bubble2: Bubble) -> void:
	if bubble1.is_in_routine or bubble2.is_in_routine:
		return
	var aggregator: BubbleAggregator = BubbleAggregator.new(bubble1, bubble2)
	add_child(aggregator)