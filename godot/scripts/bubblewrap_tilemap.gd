extends TileMapLayer

@onready var screen_size: Vector2 = get_viewport().get_visible_rect().size

var glance_timer: Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get the bubbles in scene
	await get_tree().create_timer(0.5).timeout
	GameStats.all_bubbles = get_children()
	# setup glance timer
	glance_timer.wait_time = 0.5
	add_child(glance_timer)
	glance_timer.timeout.connect(_glance_bubble)
	glance_timer.start()

func _glance_bubble() -> void:
	if GameStats.all_bubbles.size() > 0:
		# var found: bool = false
		# var random: Variant
		# while not found:
		# 	random = GameStats.all_bubbles.pick_random()
		# 	found = random is Bubble
		var pick_bubble: Bubble = GameStats.all_bubbles.pick_random()
		pick_bubble.glance()
		glance_timer.wait_time = randf_range(0.5, 3)
	else:
		glance_timer.stop()
