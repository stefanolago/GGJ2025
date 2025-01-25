extends Camera2D

# Configurable constants
const EDGE_THRESHOLD: int = 10       # Distanza dal bordo dello schermo per attivare il movimento
const CAMERA_SPEED: float = 600.0   # Velocità di movimento della telecamera (pixel al secondo)

# Process function
func _process(delta: float) -> void:
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
