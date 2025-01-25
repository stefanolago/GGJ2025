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
@export var worried_limit: int = 5


@onready var sprite: BubbleSprite = $BubbleSprite
# @onready var wandering_timer: Timer = %WanderingTimer				# Timer to handle wandering
@onready var escaping_timer: Timer = %EscapingTimer					# Timer to handle the escaping
@onready var body_anim_player: AnimationPlayer = $BodyAnimationPlayer
@onready var face_anim_player: AnimationPlayer = $FaceAnimationPlayer
@onready var pop_warning_area: Area2D = %PopWarningArea
@onready var nearby_unattached_bubble_area: Area2D = %NearbyUnattachedBubbleDetectArea
@onready var attack_marker: AttackMarker = %AttackMarker


var playing_idle_break: bool = false
var glance_anims: Array = ["Glance_1", "Glance_2", "Glance_3"]		# Array of animations that can be played
var pressed: bool = false
var health: float = 1												# Health of the bubble
var last_collision: KinematicCollision2D = null						# Last collision with another bubble
var corpses_seen: int = 0											# Tracks the number of nearby bubbles that have popped
var last_corpse_seen_position: Vector2 = Vector2.ZERO
var level:int = 1
var is_group_leader: bool = true
var leaded_bubbles: Array = []
var group_limit_to_start_revolting: int = 3
var started_revolting: bool = false


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
	#last_collision = move_and_collide(velocity)
	move_and_slide()
	for bubble: Bubble in leaded_bubbles:
		bubble.velocity = velocity


# PUBLIC METHODS _________________________________________________________________________________________________________________________
#_________________________________________________________________________________________________________________________________________
func pop() -> void:
	# pop the bubble and warn the other bubbles nearby that it popped
	for bubble: Bubble in pop_warning_area.get_overlapping_bodies():
		if bubble != self:
			bubble.nearby_bubble_popped(global_position)
	(GlobalAudio as AudioWrapper).play_one_shot("bubble_pop")
	sprite.set_face_mood("dead")
	process_mode = Node.PROCESS_MODE_DISABLED
	z_index = -1
	# create a tween that makes the alpha go from 1.0 to 0.3
	#var tween: Tween = get_tree().create_tween()
	#tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.3), 4.0)

	# remove this bubble from the list of inital bubbles
	if self in GameStats.all_bubbles:
		var index_in_list: int = GameStats.all_bubbles.find(self)
		GameStats.all_bubbles.pop_at(index_in_list)
	GameStats.bubbles_popped += 1
	attack_marker.queue_free()


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


func attack(damage_reducer_value: float) -> void:
	show_attack_marker()
	GameStats.take_damage(level * damage_reducer_value, global_position)
	GlobalAudio.play_one_shot("bubble_bite")
	sprite.set_face_mood("attack")
	

func squishy_tween() -> void:
	var tween: Tween = get_tree().create_tween()

	if randf_range(0.0, 1.0) < 0.5:
		tween.tween_property(self, "scale", Vector2(1.1, 0.9), 0.1)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	else:
		tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.1)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)


func release_bubble(weapon: Node2D) -> void:
	
	health = randf_range(min_health, max_health)
	if weapon is Finger:
		pressed = false
	# remove form the list of intial bubbles
	if self in GameStats.all_bubbles:
		var index_in_list: int = GameStats.all_bubbles.find(self)
		GameStats.all_bubbles.pop_at(index_in_list)


func merge_with_bubble(other_bubble: Bubble) -> void:
	# invert the merge verse if this bubble is not revolting
	# and the other one is
	if not started_revolting and other_bubble.started_revolting:
		other_bubble.merge_with_bubble(self)
		return


	other_bubble.is_group_leader = false
	leaded_bubbles.append(other_bubble)
	leaded_bubbles.append_array(other_bubble.leaded_bubbles)

	if leaded_bubbles.size() + 1 >= group_limit_to_start_revolting:
		started_revolting = true
		for bubble: Bubble in leaded_bubbles:
			bubble.started_revolting = true


func set_collision_with_unattached_bubbles(value: bool) -> void:
	set_collision_layer_value(6, value)
	set_collision_mask_value(6, value)

	# enable the detect nearby unattached bubbles area
	nearby_unattached_bubble_area.monitoring = value


func glance() -> void:
	var random_glance_anim: String = glance_anims.pick_random()
	face_anim_player.play(random_glance_anim)
	# body_anim_player.play("Squash")


func is_seeing_player() -> bool:
	return attack_marker.visible_on_screen_notifier.is_on_screen()

func show_attack_marker() -> void:
	if attack_marker:
		attack_marker.show_attack_hint(global_position)


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


func _on_face_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in glance_anims:
		face_anim_player.play("Idle_0")
		face_anim_player.advance(randf_range(0.0, 3.9))


func _on_body_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Squash":
		body_anim_player.play("Rotation")
		body_anim_player.advance(randf_range(0.0, 7.9))
