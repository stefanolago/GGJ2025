extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@export var camera_anim_player: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	GameStats.player_damage_bossfight.connect(_take_damage)


func _take_damage() -> void:
	show()
	progress_bar.value = GameStats.player_health_bossfight
	if camera_anim_player:
		camera_anim_player.play("camera_shake")
	
