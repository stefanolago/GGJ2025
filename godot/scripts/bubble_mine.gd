extends StaticBody2D

class_name BossAttack

static var max_health: float = 0.3
static var damage_dealt: float = 1.0

@onready var mine_anim_player: AnimationPlayer = $MineAnimationPlayer
@onready var control_anim_player: AnimationPlayer = $ControlAnimationPlayer

var health: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	mine_anim_player.play("spawn")
	GameStats.boss_killed.connect(_delete_bubble)

func hit_bubble(_weapon: Node2D, damage: float) -> void:
	health -= damage
	control_anim_player.play("hit")
	if health <= 0:
		(GlobalAudio as AudioWrapper).play_one_shot("bubble_pop")
		queue_free()

func _explode() -> void:
	GameStats.take_damage(damage_dealt, global_position)
	(GlobalAudio as AudioWrapper).play_one_shot("bomb")
	queue_free()

func _delete_bubble() -> void:
	queue_free()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "spawn":
		mine_anim_player.play("charging")
	if anim_name == "charging":
		_explode()
