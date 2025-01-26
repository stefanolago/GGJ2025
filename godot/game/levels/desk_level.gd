extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	(GlobalAudio as AudioWrapper).play_one_shot("phase_one_song")
	await get_tree().create_timer(10.0).timeout
	print("SWITCH CLIP")
	(GlobalAudio as AudioWrapper).switch_to_clip("phase_one_song", "bubble_song_2")
