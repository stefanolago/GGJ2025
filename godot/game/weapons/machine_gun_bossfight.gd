extends Weapon


@onready var hit_cooldown_timer: Timer = $HitCooldownTimer
@onready var hit_detect_area: Area2D = $HitDetectArea
@onready var sprite_control: Node2D = $MachineGunControl
@onready var hold_to_fire: AnimatedSprite2D = $HoldToFire

@export var hit_cooldown: float = 0.03
@export var hit_damage: float = 0.5

func _ready() -> void:
	active = false

func _physics_process(_delta: float) -> void:
	var mouse_global_pos: Vector2 = get_global_mouse_position()
	hit_detect_area.global_position = mouse_global_pos
	sprite_control.global_position.x = mouse_global_pos.x
	if not active:
		return
	if firing:
		# check for all of the bubbles that intersecate the area2D, and hit them
		# wait for the cooldown time before hitting again
		if hit_cooldown_timer.is_stopped():
			hit_cooldown_timer.start(hit_cooldown)
			GlobalAudio.play_one_shot("shot")
			for body: Node2D in hit_detect_area.get_overlapping_bodies():
				if body is BossBubble:
					(body as BossBubble).hit_bubble(self, hit_damage)
				if body is BossAttack:
					(body as BossAttack).hit_bubble(self, hit_damage)

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("fire"):
		firing = true
	if event.is_action_released("fire"):
		firing = false

func _activate_weapon() -> void:
	($AnimationPlayer as AnimationPlayer).play("load_weapon")
	GlobalAudio.play_one_shot("gun_load")
	hold_to_fire.show()
	await get_tree().create_timer(10).timeout
	hold_to_fire.hide()
	


	
