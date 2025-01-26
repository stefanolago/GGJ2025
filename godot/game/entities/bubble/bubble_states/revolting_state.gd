extends BubbleHumorState


const START_ATTACKING_TIME: float = 2.0
const ATTACK_TIME_MIN: float = 1.0
const ATTACK_TIME_MAX: float = 3.0
const DAMAGE_REDUCER_VALUE: float = 0.03

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

	#first_attack_timer = RuntimeTimer._init_timer(START_ATTACKING_TIME, true, false, _on_first_attack_timeout)


func exit() -> void:
	super()
	attack_timer.queue_free()


func physics_update(delta: float) -> void:
	super(delta)
	# move the bubble toward the camera position
	if not bubble.is_seeing_player():
		var target_position: Vector2 = get_viewport().get_camera_2d().global_position
		bubble.global_position = bubble.global_position.move_toward(target_position, move_speed * delta)



func _on_first_attack_timeout() -> void:
	attack_timer.start()


func _on_attack_timeout() -> void:
	if bubble.process_mode == Node.PROCESS_MODE_DISABLED:
		return
	#if bubble.is_seeing_player():
	bubble.attack(DAMAGE_REDUCER_VALUE)
	
	attack_timer.wait_time = _get_attack_time()
	attack_timer.start()


func _get_attack_time() -> float:
	return randf_range(ATTACK_TIME_MIN, ATTACK_TIME_MAX)
