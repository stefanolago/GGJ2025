extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.timeline_ended.connect(_end_game)
	Dialogic.start("ending")

func _end_game() -> void:
	get_tree().quit()
