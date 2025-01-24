extends CharacterBody2D
class_name Bubble

signal nearby_popped

@export var max_health: float = 0.5
@export var min_health: float = 0.1
@export var min_wander_timer: float = 2.0
@export var max_wander_timer: float = 7.0

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
var health: float = 1												# Health of the bubble
var last_collision: KinematicCollision2D = null						# Last collision with another bubble
var corpses_seen: int = 0: set = _set_corpses_seen					# Tracks the number of nearby bubbles that have popped
var level:int = 1

# Atomic modification of corpses_seen
func _set_corpses_seen(value: int) -> void:
	corpses_seen = value

var assigned_routine: RoutineManager.BubbleRoutine = RoutineManager.BubbleRoutine.NONE

var is_in_routine: bool = false


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
	if is_detached and not is_in_routine:
		# Move the bubble randomly
		last_collision = move_and_collide(velocity)



# PUBLIC METHODS _________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func pop() -> void:
	# pop the bubble and warn the other bubbles nearby that it popped
	for bubble: Bubble in pop_warning_area.get_overlapping_bodies():
		if bubble != self:
			bubble.nearby_bubble_popped(global_position)
	GlobalAudio.play_one_shot("bubble_pop")
	sprite.set_face_mood("dead")
	process_mode = Node.PROCESS_MODE_DISABLED


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
		velocity = RoutineManager.get_roaming_velocity()
		assigned_routine = RoutineManager.get_random_routine()
		wander_timer.start()  # Start the wander timer


func glance() -> void:
	body_anim_player.play("Squash")
	var random_glance_anim: String = glance_anims.pick_random()
	face_anim_player.play(random_glance_anim)


func exit_from_routine() -> void:
	velocity = RoutineManager.get_roaming_velocity()
	is_in_routine = false



# PRIVATE METHODS ________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _set_wander_time() -> void:
	wander_timer.wait_time = randf_range(min_wander_timer, max_wander_timer)


# Handle collisions with an other bubbles that is in the same routine
func _handle_bubble_collision(_other_bubble: Bubble) -> void:
	match assigned_routine:
		RoutineManager.BubbleRoutine.GROUP_UP:
			if not _other_bubble.is_in_routine:
				RoutineManager.aggregate(self, _other_bubble)
		RoutineManager.BubbleRoutine.FAMILY_BUILDING:
			if not _other_bubble.is_in_routine:
				RoutineManager.form_family(self, _other_bubble)
		RoutineManager.BubbleRoutine.COMMUNITY_BUILDING:
			#_start_routine_form_community()
			pass


func _handle_wall_collision() -> void:
	if assigned_routine == RoutineManager.BubbleRoutine.ATTACK_WALL:
		#_start_routine_attack_wall()
		pass


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
	if not is_in_routine:
		velocity = RoutineManager.get_roaming_velocity()
		_set_wander_time()


func _on_detach_test_timer_timeout() -> void:
	detach()


func _on_face_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in glance_anims:
		face_anim_player.play("Idle_0")
		face_anim_player.advance(randf_range(0.0, 3.9))


func _on_body_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Squash":
		body_anim_player.play("Rotation")
		body_anim_player.advance(randf_range(0.0, 7.9))

		

# COLLIDERS ______________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _on_pop_warning_area_body_entered(body: Node2D) -> void:
	if body == self or not is_detached:
		return
	print("Collisione con " + body.name)
	if body is Bubble:
		var other_bubble: Bubble = body as Bubble
		if assigned_routine == other_bubble.assigned_routine:
			_handle_bubble_collision(other_bubble)
	elif body.is_in_group("walls"):
		_handle_wall_collision()
