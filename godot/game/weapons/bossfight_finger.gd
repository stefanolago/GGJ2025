extends Weapon

class_name BossfightFinger

@onready var hit_detect_area: Area2D = $HitDetectArea

@export var hit_cooldown: float = 0.1
@export var hit_damage: float = 0.1

func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		# check for all of the bubbles that intersecate the area2D, and hit them
		var overlapping_bodies: Array = hit_detect_area.get_overlapping_bodies()
		# boss attacks block any other damage
		for body: Node2D in overlapping_bodies:
			if body is BossAttack:
				(body as BossAttack).hit_bubble(self, hit_damage)
				return
		for body: Node2D in overlapping_bodies:
			if body is BossBubble:
				(body as BossBubble).hit_bubble(self, hit_damage)
