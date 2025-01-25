extends CanvasLayer

@export var good_ending: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if good_ending:
		await get_tree().create_timer(15).timeout
		_end_game()
	else:
		Dialogic.timeline_ended.connect(_end_game)
		Dialogic.start("ending")

func _end_game() -> void:
	get_tree().quit()
