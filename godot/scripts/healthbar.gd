extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@export var camera_anim_player: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	progress_bar.max_value = GameStats.HEALT
	GameStats.player_damage.connect(_update_health)


func _update_health(health: float, _damage_location: Vector2) -> void:
	show()
	print("danno")
	progress_bar.value = health
	if camera_anim_player:
		camera_anim_player.play("camera_shake")
	
