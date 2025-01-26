extends Camera2D

# MOUSE INPUT__________________________________________________________________________________________________
# Configurable constants
const EDGE_THRESHOLD: int = 10       # Distanza dal bordo dello schermo per attivare il movimento
const CAMERA_SPEED: float = 600.0   # Velocità di movimento della telecamera (pixel al secondo)
const TOUCH_SENSITIVITY: float = 1.5 # Sensibilità del movimento sul touch

# Process function
func _process(delta: float) -> void:
	if OS.get_name() == "Windows":
		_process_windows(delta)

# Movimento su Windows (mouse)
func _process_windows(delta: float) -> void:
	# Ottieni la posizione del mouse rispetto alla finestra
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	
	# Variabile per accumulare il movimento della telecamera
	var camera_motion: Vector2 = Vector2.ZERO
	
	# Controlla i bordi dello schermo
	if mouse_position.x <= EDGE_THRESHOLD:
		camera_motion.x -= CAMERA_SPEED * delta
	elif mouse_position.x >= viewport_size.x - EDGE_THRESHOLD:
		camera_motion.x += CAMERA_SPEED * delta
	
	if mouse_position.y <= EDGE_THRESHOLD:
		camera_motion.y -= CAMERA_SPEED * delta
	elif mouse_position.y >= viewport_size.y - EDGE_THRESHOLD:
		camera_motion.y += CAMERA_SPEED * delta
	
	# Aggiorna la posizione della telecamera
	global_position += camera_motion


# TOUCH INPUT__________________________________________________________________________________________________
@export var pan_speed: float = 2.0

var touch_points: Dictionary = {}
var start_distance: float


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		handle_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		handle_drag(event as InputEventScreenDrag)

		
func handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		touch_points[event.index] = event.position
	else:
		touch_points.erase(event.index)
	
	if touch_points.size() == 2:
		var touch_point_positions: Array = touch_points.values()
		start_distance = (touch_point_positions[0] - touch_point_positions[1]).length
	elif touch_points.size() < 2:
		start_distance = 0
		

func handle_drag(event: InputEventScreenDrag) -> void:
	touch_points[event.index] = event.position
	
	if touch_points.size() == 1:
		global_position -= event.relative * pan_speed


