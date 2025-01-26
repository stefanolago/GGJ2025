extends Camera2D

var viewport_size: Vector2
var viewport_size_half_x: float
var viewport_size_half_y: float
var new_position: Vector2


func _ready() -> void:
	viewport_size = get_viewport().get_visible_rect().size
	viewport_size_half_x = viewport_size.x / (2 * zoom.x)
	viewport_size_half_y = viewport_size.y /  (2 * zoom.y)



# MOUSE INPUT__________________________________________________________________________________________________
# Configurable constants
const EDGE_THRESHOLD: int = 10       # Distanza dal bordo dello schermo per attivare il movimento
const CAMERA_SPEED: float = 800.0   # Velocità di movimento della telecamera (pixel al secondo)
const TOUCH_SENSITIVITY: float = 1.5 # Sensibilità del movimento sul touch

# Process function
func _physics_process(delta: float) -> void:
	if OS.get_name() == "Windows":
		_process_windows(delta)

# Movimento su Windows (mouse)
func _process_windows(delta: float) -> void:
	# Ottieni la posizione del mouse rispetto alla finestra
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	
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
	
	# Calcola la nuova posizione globale
	new_position = global_position + camera_motion
	
	# Applica i limiti
	new_position.x = clamp(new_position.x, limit_left + viewport_size_half_x, limit_right - viewport_size_half_x)
	new_position.y = clamp(new_position.y, limit_top + viewport_size_half_y, limit_bottom - viewport_size_half_y)
	
	# Aggiorna la posizione della telecamera
	global_position = new_position




# TOUCH INPUT__________________________________________________________________________________________________
@export var pan_speed: float = 2.0

var touch_points: Dictionary = {}
var start_distance: float


func _unhandled_input(event: InputEvent) -> void:
	if OS.get_name() == "Android":
		if event is InputEventScreenDrag:
			handle_drag(event as InputEventScreenDrag)

		

func handle_drag(event: InputEventScreenDrag) -> void:
	touch_points[event.index] = event.position
	
	if touch_points.size() == 1:
		new_position = global_position - event.relative * pan_speed
		new_position.x = clamp(new_position.x, limit_left + viewport_size_half_x, limit_right - viewport_size_half_x)
		new_position.y = clamp(new_position.y, limit_top + viewport_size_half_y, limit_bottom - viewport_size_half_y)
		global_position = new_position
	else:
		touch_points.clear()
