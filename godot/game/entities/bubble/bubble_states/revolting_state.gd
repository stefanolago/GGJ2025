extends BubbleHumorState

const START_ATTACKING_TIME: float = 3.0
const ATTACK_TIME_MIN: float = 1.0
const ATTACK_TIME_MAX: float = 6.0
const DAMAGE_REDUCER_VALUE: float = 0.02

var first_attack_timer: Timer
var attack_timer: Timer


func enter() -> void:
	super()
	attack_timer = RuntimeTimer._init_timer(_get_attack_time(), false, false, _on_attack_timeout)
	first_attack_timer = RuntimeTimer._init_timer(START_ATTACKING_TIME, true, true, _on_first_attack_timeout)


func exit() -> void:
	super()
	attack_timer.queue_free()


func _on_first_attack_timeout() -> void:
	attack_timer.start()


func _on_attack_timeout() -> void:
	if bubble.is_seeing_player():
		GameStats.take_damage(bubble.level * DAMAGE_REDUCER_VALUE, bubble.global_position)
	attack_timer.wait_time = _get_attack_time()


func _get_attack_time() -> float:
	return randf_range(ATTACK_TIME_MIN, ATTACK_TIME_MAX)
