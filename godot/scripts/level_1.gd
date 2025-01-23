extends CanvasLayer

@export var tile_map: TileMapLayer

var bubble_detach_timer: Timer = Timer.new()
var all_bubbles: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get the bubbles in scene
	await get_tree().create_timer(0.5).timeout
	all_bubbles = tile_map.get_children()
	all_bubbles.shuffle()
	# setup timer to spawn bubbles
	bubble_detach_timer.wait_time = 1
	add_child(bubble_detach_timer)
	bubble_detach_timer.timeout.connect(_detach_bubble)
	bubble_detach_timer.start()

func _detach_bubble() -> void:
	if all_bubbles:
		var pick_bubble: Bubble = all_bubbles.pop_front()
		pick_bubble.detach()
		if bubble_detach_timer.wait_time > 0.1:
			bubble_detach_timer.wait_time -= 0.15
