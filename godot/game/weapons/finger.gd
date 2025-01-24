extends Weapon

class_name Finger

@onready var hit_cooldown_timer: Timer = $HitCooldownTimer
@onready var hit_detect_area: Area2D = $HitDetectArea

@export var hit_cooldown: float = 0.1
@export var hit_damage: float = 0.1

func _physics_process(_delta: float) -> void:
	if firing:
		# check for all of the bubbles that intersecate the area2D, and hit them
		# wait for the cooldown time before hitting again
		if hit_cooldown_timer.is_stopped():
			hit_cooldown_timer.start(hit_cooldown)
			for body: Node2D in hit_detect_area.get_overlapping_bodies():
				if body is Bubble:
					(body as Bubble).hit_bubble(self, hit_damage)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		global_position = get_global_mouse_position()
		firing = true
	
	if event.is_action_released("fire"):
		firing = false
