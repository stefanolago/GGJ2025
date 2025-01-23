extends CanvasLayer

@export var tile_map: TileMapLayer

@onready var screen_size: Vector2 = get_viewport().get_visible_rect().size

# var bubble_detach_timer: Timer = Timer.new()
var glance_timer: Timer = Timer.new()
var anim_idle_timer: Timer = Timer.new()
var all_bubbles: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get the bubbles in scene
	await get_tree().create_timer(0.5).timeout
	all_bubbles = tile_map.get_children()
	# setup glance timer
	glance_timer.wait_time = 0.5
	add_child(glance_timer)
	glance_timer.timeout.connect(_glance_bubble)
	glance_timer.start()
	# setup idle timer
	anim_idle_timer.wait_time = 0.5
	add_child(anim_idle_timer)
	anim_idle_timer.timeout.connect(_idle_anim_bubble)
	anim_idle_timer.start()

func _idle_anim_bubble() -> void:
	var pick_bubble: Bubble = all_bubbles.pick_random()
	pick_bubble.play_idle_break()
	anim_idle_timer.wait_time = randf_range(0.5, 2)
	
func _glance_bubble() -> void:
	var pick_bubble: Bubble = all_bubbles.pick_random()
	@warning_ignore("narrowing_conversion")
	var random_screen_pos_x: int = randi_range(0, screen_size[0])
	@warning_ignore("narrowing_conversion")
	var random_screen_pos_y: int = randi_range(0, screen_size[1])
	pick_bubble.glance(Vector2(random_screen_pos_x, random_screen_pos_y))
	glance_timer.wait_time = randf_range(0.2, 1.5)
