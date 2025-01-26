extends BubbleHumorState


const START_ATTACKING_TIME: float = 5.0
const ATTACK_TIME_MIN: float = 1.0
const ATTACK_TIME_MAX: float = 10.0
const DAMAGE_REDUCER_VALUE: float = 0.03
const MAX_ATTACK_RANGE_SQUARED: float = 6000000.0

var first_attack_timer: Timer
var attack_timer: Timer
var move_speed: float = 200.0


func enter() -> void:
	super()
	bubble.velocity = Vector2.ZERO
	bubble.sprite.max_distance_look_at_mouse = 0
	bubble.sprite.set_face_mood("angry")
	attack_timer = RuntimeTimer._init_timer(_get_attack_time(), false, false, _on_attack_timeout)
	await get_tree().create_timer(START_ATTACKING_TIME).timeout
	_on_first_attack_timeout()
	bubble.body_anim_player.play("Squash")

	if not GameStats.revolt_started:
		GameStats.revolt_started = true


	#first_attack_timer = RuntimeTimer._init_timer(START_ATTACKING_TIME, true, false, _on_first_attack_timeout)


func exit() -> void:
	super()
	attack_timer.queue_free()


func physics_update(delta: float) -> void:
	super(delta)
	# move the bubble toward the camera position
	if not bubble.is_seeing_player():
		var target_position: Vector2 = get_viewport().get_camera_2d().global_position
		bubble.velocity = bubble.global_position.direction_to(target_position) * move_speed
	else:
		bubble.velocity = lerp(bubble.velocity, Vector2.ZERO, 0.3)


func _on_first_attack_timeout() -> void:
	attack_timer.start()


func _on_attack_timeout() -> void:
	if bubble.process_mode == Node.PROCESS_MODE_DISABLED:
		return

	# attack only if the bubble is in range
	if bubble.global_position.distance_squared_to(get_viewport().get_camera_2d().global_position) > MAX_ATTACK_RANGE_SQUARED:
		if bubble.attack_marker.visible:
			bubble.attack_marker._fade_out()
		return

	bubble.attack(DAMAGE_REDUCER_VALUE)
	
	attack_timer.wait_time = _get_attack_time()
	attack_timer.start()


func _get_attack_time() -> float:
	return randf_range(ATTACK_TIME_MIN, ATTACK_TIME_MAX)
