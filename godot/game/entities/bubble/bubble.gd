extends CharacterBody2D
class_name Bubble

@export var max_health: float = 1.0
@onready var sprite: Sprite2D = $BubbleSprite
@onready var wander_timer: Timer = %WanderTimer						# Timer to handle wandering
@onready var family_timer: Timer = %FamilyTimer						# Timer to handle family creation

var is_detached: bool = false										# Indicates if the bubble is stationary
var pressed: bool = false
var health: float = 1													# Health of the bubble
var speed: float = 10.00											# Speed of the bubble
var last_collision: KinematicCollision2D = null						# Last collision with another bubble
var corpses_seen: int = 0: set = _set_corpses_seen					# Tracks the number of nearby bubbles that have popped
# Atomic modification of corpses_seen
func _set_corpses_seen(value: int) -> void:
	corpses_seen = value

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
func _ready() -> void:
	health = max_health
	

func hit_bubble(weapon: Node2D, damage: float) -> void:
	print("HIT BY: " + weapon.name + " DAMAGE: " + str(damage))
	health -= damage
	print("HEALTH: " + str(health))
	if weapon is Finger:
		pressed = true


func _physics_process(_delta: float) -> void:
	if is_detached:
		# Move the bubble randomly
		last_collision = move_and_collide(velocity)

		# Handle collisions
		#if last_collision:
			#if last_collision.get_collider().is_in_group("bubbles"):
			#	handle_bubble_collision(last_collision.get_collider())
			#elif last_collision.get_collider().is_in_group("walls"):
			#	_handle_wall_collision()



#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func nearby_bubble_popped() -> void:
	corpses_seen = corpses_seen + 1

func change_color(color: Color) -> void:
	sprite.modulate = color


# Detach function: Makes the bubble mobile and starts its routine
func detach() -> void:
	if not is_detached:
		is_detached = true
		velocity = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized() * speed
		wander_timer.start()  # Inizia a girovagare
		print("Bubble detached and wandering.")


# Routine 1: Bubble attacks the wall to create a breach
func start_routine_attack_wall() -> void:
	var wall_direction: Vector2 = (get_viewport_rect().size / 2 - global_position).normalized()
	move_and_collide(wall_direction * 100)  		# Adjust speed as needed


# Routine 2: Bubble gathers with others to form a larger bubble
func start_routine_group_up() -> void:
	var bubbles: Array = get_tree().get_nodes_in_group("bubbles")
	for bubble: Bubble in bubbles:
		if bubble != self:
			pass
			# TODO move_and_slide((bubble.global_position - global_position).normalized() * 50)  # Adjust speed

	# When close enough, merge
	if bubbles.size() > 0:
		health += bubbles.size()


# Routine 3: Bubble creates a family
func start_routine_create_family() -> void:
	var partner: Bubble = find_closest_bubble()
	if partner:
		# TODO move_and_slide((partner.global_position - global_position).normalized() * 30)  # Adjust speed

		if position.distance_to(partner.global_position) < 10:
			# Start the family creation timer
			family_timer.start()
			family_timer.timeout.connect(_on_family_created)


func _on_family_created() -> void:
	var child_bubble: Bubble = Bubble.new()
	add_child(child_bubble)
	child_bubble.global_position = global_position
	child_bubble.is_detached = true
	child_bubble.start_routine_attack_wall()  # Child starts its routine


# Routine 4: Bubble forms a community
func start_routine_form_community() -> void:
	var bubbles: Array = get_tree().get_nodes_in_group("bubbles")
	if bubbles.size() >= 5:
		for bubble: Bubble in bubbles:
			pass
			# TODO move_and_slide((bubble.global_position - global_position).normalized() * 20)  # Adjust speed

		# Boost stats for all bubbles in the community
		health += 10 * bubbles.size()


# Helper function: Finds the closest bubble
func find_closest_bubble() -> Bubble:
	var closest_bubble: Bubble = null
	var closest_distance: float = INF

	var bubbles: Array = get_tree().get_nodes_in_group("bubbles")
	for bubble: Bubble in bubbles:
		if bubble != self:
			var distance: float = global_position.distance_to(bubble.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_bubble = bubble

	return closest_bubble


func _on_timer_timeout() -> void:
	corpses_seen += 1
func release_bubble(weapon: Node2D) -> void:
	print("RELEASED BY: " + weapon.name)

	health = max_health
	
	if weapon is Finger:
		pressed = false
