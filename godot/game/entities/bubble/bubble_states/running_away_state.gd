extends BubbleHumorState

@export var run_away_duration: float = 1.5
@export var run_away_speed: float = 1500.0

func enter() -> void:
	super()
	bubble.z_index = 1
	
	# move the bubble away from the bubble last seen corpse 
	bubble.velocity = -1 * bubble.global_position.direction_to(bubble.last_corpse_seen_position) * run_away_speed



func physics_update(delta: float) -> void:
	super(delta)
	run_away_duration -= delta
	if run_away_duration <= 0.0:
		transition.emit("LookingForCompanions")

	




