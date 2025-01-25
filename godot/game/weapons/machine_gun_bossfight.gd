extends Weapon


@onready var hit_cooldown_timer: Timer = $HitCooldownTimer
@onready var hit_detect_area: Area2D = $HitDetectArea

@export var hit_cooldown: float = 0.03
@export var hit_damage: float = 0.5

func _ready() -> void:
	active = false

func _physics_process(_delta: float) -> void:
	if not active:
		return
	global_position = get_global_mouse_position()
	if firing:
		# check for all of the bubbles that intersecate the area2D, and hit them
		# wait for the cooldown time before hitting again
		if hit_cooldown_timer.is_stopped():
			hit_cooldown_timer.start(hit_cooldown)
			for body: Node2D in hit_detect_area.get_overlapping_bodies():
				if body is BossBubble:
					(body as BossBubble).hit_bubble(self, hit_damage)

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("fire"):
		firing = true
	if event.is_action_released("fire"):
		firing = false
