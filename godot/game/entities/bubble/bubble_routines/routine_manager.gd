extends Node


# Configurable constants
const FAMILY_MEETING_DISTANCE: float = 250.0
const FAMILY_PROCREATING_TIME: float = 5.0      							# Time required to form a child

const AGGREGATION_MEETING_DISTANCE: float = 20.0
const AGGREGATION_TIME: float = 3.0      									# Time required for the aggregation

const FOUNDATION_MEETING_DISTANCE: float = 300.0
const FOUNDING_TIME: float = 4.0      										# Time required for found a city


# Configurable variables
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



#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
# Returns a random routine
func get_random_routine() -> BubbleRoutine:
	#return BubbleRoutine.values()[randi() % BubbleRoutine.size()]
	return BubbleRoutine.GROUP_UP


func get_roaming_velocity() -> Vector2:
	return _get_random_velocity(randf_range(roaming_speed_min, roaming_speed_max))


func get_walking_velocity() -> Vector2:
	return _get_random_velocity(walking_speed)


func form_family(bubble1: Bubble, bubble2: Bubble) -> void:
	# Create a family with two bubbles
	if bubble1.is_in_routine or bubble2.is_in_routine:
		return
	var family: Family = Family.new(bubble1, bubble2, FAMILY_MEETING_DISTANCE, FAMILY_PROCREATING_TIME)
	add_child(family)
	families.append(family)


func aggregate(bubble1: Bubble, bubble2: Bubble) -> void:
	if bubble1.is_in_routine or bubble2.is_in_routine:
		return
	var aggregator: Aggregation = Aggregation.new(bubble1, bubble2, AGGREGATION_MEETING_DISTANCE, AGGREGATION_TIME)
	add_child(aggregator)



#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _get_random_velocity(speed: float) -> Vector2:
	return Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized() * speed
