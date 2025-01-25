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
# @onready var wandering_timer: Timer = %WanderingTimer				# Timer to handle wandering
@onready var escaping_timer: Timer = %EscapingTimer					# Timer to handle the escaping
@onready var body_anim_player: AnimationPlayer = $BodyAnimationPlayer
@onready var face_anim_player: AnimationPlayer = $FaceAnimationPlayer
@onready var pop_warning_area: Area2D = %PopWarningArea
@onready var nearby_unattached_bubble_area: Area2D = %NearbyUnattachedBubbleDetectArea
@onready var visible_on_screen_notifier: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D


# var behavior: Behavior = Behavior.ATTACHED: set = _set_behavior
var playing_idle_break: bool = false
var glance_anims: Array = ["Glance_1", "Glance_2", "Glance_3"]		# Array of animations that can be played
var pressed: bool = false
var health: float = 1												# Health of the bubble
var last_collision: KinematicCollision2D = null						# Last collision with another bubble
var corpses_seen: int = 0: set = _set_corpses_seen					# Tracks the number of nearby bubbles that have popped
var last_corpse_seen_position: Vector2 = Vector2.ZERO
var level:int = 1
var is_in_routine: bool = false
var is_group_leader: bool = true
var group_count: int = 1
#var assigned_routine: RoutineManager.BubbleRoutine = RoutineManager.BubbleRoutine.NONE

func _set_corpses_seen(value: int) -> void:
	corpses_seen = value

# func _set_behavior(value: Behavior) -> void:
# 	behavior = value
# 	match behavior:
# 		Behavior.ATTACHED:
# 			pass
# 		Behavior.WANDERING:
# 			_set_wandering_behavior()
# 		Behavior.ESCAPING:
# 			_set_escaping_behavior()



#_________________________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func _ready() -> void:
	health = randf_range(min_health, max_health)
	# _set_wander_time()
	face_anim_player.play("Idle_0")
	face_anim_player.advance(randf_range(0.0, 5.9))
	body_anim_player.play("Rotation")
	body_anim_player.advance(randf_range(0.0, 7.9))


func _physics_process(_delta: float) -> void:
	# if behavior == Behavior.ATTACHED or is_in_routine:
	# 	return
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
	# remove this bubble from the list of inital bubbles
	if self in GameStats.all_bubbles:
		var index_in_list: int = GameStats.all_bubbles.find(self)
		GameStats.all_bubbles.pop_at(index_in_list)


func nearby_bubble_popped(bubble_position: Vector2) -> void:
	corpses_seen = corpses_seen + 1
	last_corpse_seen_position = bubble_position
	nearby_popped.emit(bubble_position)


func change_color(_color: Color) -> void:
	pass
	#sprite.modulate = color


func hit_bubble(weapon: Node2D, damage: float) -> void:
	health -= damage
	if weapon is Finger:
		pressed = true


func release_bubble(weapon: Node2D) -> void:
	
	health = randf_range(min_health, max_health)
	if weapon is Finger:
		pressed = false
	# remove form the list of intial bubbles
	if self in GameStats.all_bubbles:
		var index_in_list: int = GameStats.all_bubbles.find(self)
		GameStats.all_bubbles.pop_at(index_in_list)


func merge_with_bubble(other_bubble: Bubble) -> void:
	other_bubble.is_group_leader = false
	other_bubble.reparent(self)
	#other_bubble.set_collision_layer_value(6, false)
	group_count += 1

# func manage_panic() -> void:
# 	# Detach bubble: Makes the bubble mobile and starts its routine
# 	if behavior == Behavior.ATTACHED:
# 		behavior = Behavior.ESCAPING
# 	else:
# 		behavior = Behavior.ESCAPING


func glance() -> void:
	var random_glance_anim: String = glance_anims.pick_random()
	face_anim_player.play(random_glance_anim)
	# body_anim_player.play("Squash")


func exit_from_routine() -> void:
	#velocity = RoutineManager.get_roaming_velocity()
	is_in_routine = false


func is_seeing_player() -> bool: return visible_on_screen_notifier.is_on_screen()



# PRIVATE METHODS ________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
#func _set_specific_behavior(behavior_velocity: Vector2, routine: RoutineManager.BubbleRoutine, timer:Timer) -> void:
	# velocity = behavior_velocity
	# assigned_routine = routine
	#timer.start()

# func _set_escaping_behavior() -> void:
	#_set_specific_behavior(RoutineManager.get_escaping_velocity(), RoutineManager.BubbleRoutine.NONE, escaping_timer)

# func _set_wandering_behavior() -> void:
	#_set_specific_behavior(RoutineManager.get_roaming_velocity(), RoutineManager.get_random_routine(), wandering_timer)

# func _set_wander_time() -> void:
# 	wandering_timer.wait_time = randf_range(min_wander_timer, max_wander_timer)


# Handle collisions with an other bubbles that is in the same routine
# func _handle_bubble_collision(_other_bubble: Bubble) -> void:
	# match assigned_routine:
	# 	RoutineManager.BubbleRoutine.GROUP_UP:
	# 		if not _other_bubble.is_in_routine:
	# 			RoutineManager.aggregate(self, _other_bubble)
	# 	RoutineManager.BubbleRoutine.FAMILY_BUILDING:
	# 		if not _other_bubble.is_in_routine:
	# 			RoutineManager.form_family(self, _other_bubble)
		#RoutineManager.BubbleRoutine.COMMUNITY_BUILDING:
			#_start_routine_form_community()
			

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
# func _on_wander_timer_timeout() -> void:
# 	if behavior == Behavior.WANDERING and not is_in_routine:
# 		#velocity = RoutineManager.get_roaming_velocity()
# 		_set_wander_time()


# func _on_escaping_timer_timeout() -> void:
# 	if behavior == Behavior.ESCAPING:
# 		behavior = Behavior.WANDERING
# 		corpses_seen = 0


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
# func _on_pop_warning_area_body_entered(body: Node2D) -> void:
# 	if body == self or behavior == Behavior.ATTACHED:
# 		return
# 	if body is Bubble:
# 		var other_bubble: Bubble = body as Bubble
		# if assigned_routine == other_bubble.assigned_routine:
		# 	_handle_bubble_collision(other_bubble)
