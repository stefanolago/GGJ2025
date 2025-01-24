extends CharacterBody2D
class_name Bubble

signal nearby_popped

@export var max_health: float = 0.5
@export var min_health: float = 0.1
@export var min_wander_timer: int
@export var max_wander_timer: int

@export_group("Bubble worry limit")
@export var happy_limit: int = 2
@export var less_happy_limit: int = 4
@export var worried_limit: int = 6


@onready var sprite: BubbleSprite = $BubbleSprite
@onready var wander_timer: Timer = %WanderTimer						# Timer to handle wandering
@onready var family_timer: Timer = %FamilyTimer						# Timer to handle family creation
@onready var body_anim_player: AnimationPlayer = $BodyAnimationPlayer
@onready var face_anim_player: AnimationPlayer = $FaceAnimationPlayer
@onready var pop_warning_area: Area2D = %PopWarningArea

var playing_idle_break: bool = false
var glance_anims: Array = ["Glance_1", "Glance_2", "Glance_3"]	# Array of animations that can be played
var is_detached: bool = false										# Indicates if the bubble is stationary
var pressed: bool = false
var health: float = 1													# Health of the bubble
var speed: float = 10.00											# Speed of the bubble
var last_collision: KinematicCollision2D = null						# Last collision with another bubble
var corpses_seen: int = 0: set = _set_corpses_seen					# Tracks the number of nearby bubbles that have popped

# Atomic modification of corpses_seen
func _set_corpses_seen(value: int) -> void:
	corpses_seen = value

var assigned_routine: BubbleRoutine = BubbleRoutine.NONE
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
	health = randf_range(min_health, max_health)
	_set_wander_time()
	face_anim_player.play("Idle_0")
	face_anim_player.advance(randf_range(0.0, 5.9))
	body_anim_player.play("Rotation")
	body_anim_player.advance(randf_range(0.0, 7.9))


func _physics_process(_delta: float) -> void:
	if is_detached:
		# Move the bubble randomly
		last_collision = move_and_collide(velocity)

		# Handle collisions
		if last_collision:
			if last_collision.get_collider() is Bubble:
				_handle_bubble_collision((last_collision.get_collider() as Bubble))
			elif (last_collision.get_collider() as Node).is_in_group("walls"):
				_handle_wall_collision()



# PUBLIC METHODS _________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func pop() -> void:
	# pop the bubble and warn the other bubbles nearby that it popped
	for bubble: Bubble in pop_warning_area.get_overlapping_bodies():
		if bubble != self:
			bubble.nearby_bubble_popped(global_position)
	GlobalAudio.play_one_shot("bubble_pop")
	queue_free()


func nearby_bubble_popped(bubble_position: Vector2) -> void:
	corpses_seen = corpses_seen + 1
	nearby_popped.emit(bubble_position)


func change_color(color: Color) -> void:
	sprite.modulate = color


func hit_bubble(weapon: Node2D, damage: float) -> void:
	health -= damage
	if weapon is Finger:
		pressed = true


func release_bubble(weapon: Node2D) -> void:
	
	health = randf_range(min_health, max_health)
	if weapon is Finger:
		pressed = false


# Detach function: Makes the bubble mobile and starts its routine
func detach() -> void:
	if not is_detached:
		is_detached = true
		velocity = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized() * speed
		assigned_routine = BubbleRoutine.values()[randi() % BubbleRoutine.size()]  # Choose a random routine
		wander_timer.start()  # Start the wander timer


func glance() -> void:
	body_anim_player.play("Squash")
	var random_glance_anim: String = glance_anims.pick_random()
	face_anim_player.play(random_glance_anim)


# ROUTINES _______________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
# Routine 1: Bubble attacks the wall to create a breach
func _start_routine_attack_wall() -> void:
	var wall_direction: Vector2 = (get_viewport_rect().size / 2 - global_position).normalized()
	move_and_collide(wall_direction * 100)  		# Adjust speed as needed


# Routine 2: Bubble gathers with others to form a larger bubble
func _start_routine_group_up() -> void:
	var bubbles: Array = get_tree().get_nodes_in_group("bubbles")
	for bubble: Bubble in bubbles:
		if bubble != self:
			pass
			# TODO move_and_slide((bubble.global_position - global_position).normalized() * 50)  # Adjust speed

	# When close enough, merge
	if bubbles.size() > 0:
		health += bubbles.size()


# Routine 3: Bubble creates a family
func _start_routine_create_family() -> void:
	var partner: Bubble = _find_closest_bubble()
	if partner:
		# TODO move_and_slide((partner.global_position - global_position).normalized() * 30)  # Adjust speed

		if position.distance_to(partner.global_position) < 10:
			family_timer.start()


# Routine 4: Bubble forms a community
func _start_routine_form_community() -> void:
	var bubbles: Array = get_tree().get_nodes_in_group("bubbles")
	if bubbles.size() >= 5:
		for bubble: Bubble in bubbles:
			pass
			# TODO move_and_slide((bubble.global_position - global_position).normalized() * 20)  # Adjust speed

		# Boost stats for all bubbles in the community
		health += 10 * bubbles.size()



# PRIVATE METHODS ________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _set_wander_time() -> void:
	wander_timer.wait_time = randf_range(min_wander_timer, max_wander_timer)


func _handle_bubble_collision(_other_bubble: Bubble) -> void:
	match assigned_routine:
		BubbleRoutine.GROUP_UP:
			_start_routine_group_up()
		BubbleRoutine.FAMILY_BUILDING:
			_start_routine_create_family()
		BubbleRoutine.COMMUNITY_BUILDING:
			_start_routine_form_community()


func _handle_wall_collision() -> void:
	if assigned_routine == BubbleRoutine.ATTACK_WALL:
		_start_routine_attack_wall()


func _find_closest_bubble() -> Bubble:
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



# SIGNALS ________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________

# Bubble creates a family
func _on_family_timer_timeout() -> void:
	var child_bubble: Bubble = Bubble.new()
	add_child(child_bubble)
	child_bubble.global_position = global_position
	child_bubble.is_detached = true
	(child_bubble as Bubble)._start_routine_attack_wall()  # Child starts its routine


func _on_wander_timer_timeout() -> void:
	velocity = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized() * speed
	_set_wander_time()


func _on_face_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in glance_anims:
		face_anim_player.play("Idle_0")
		face_anim_player.advance(randf_range(0.0, 3.9))


func _on_body_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Squash":
		body_anim_player.play("Rotation")
		body_anim_player.advance(randf_range(0.0, 7.9))
