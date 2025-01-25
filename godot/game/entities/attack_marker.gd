extends Node2D

# References to the marker and the camera
@export var marker: Node2D
@export var camera: Camera2D

func _ready() -> void:
	hide()
	GameStats.player_damage.connect(_on_global_position_emitted)


func _on_global_position_emitted(_damage: float, damage_position: Vector2) -> void:
	show()
	# Get the visible rectangle of the camera
	var camera_rect: Rect2 = get_camera_viewport_rect()

	# Check if the position is inside the visible rectangle
	if camera_rect.has_point(damage_position):
		marker.visible = false                                                                                              # Hide the marker if the position is visible
	else:
		# Calculate the intersection point and position the marker
		var marker_position: Vector2 = _get_marker_position(damage_position, camera_rect)
		marker.global_position = marker_position
		marker.visible = true


func _get_marker_position(target_position: Vector2, camera_rect: Rect2) -> Vector2:
	# Get the center of the camera (in global coordinates)
	var camera_center: Vector2 = camera.global_position

	# Calculate the limits of the visible rectangle (in global coordinates)
	var top_left: Vector2 = camera_rect.position
	var bottom_right: Vector2 = camera_rect.position + camera_rect.size

	# Calculate the direction from the camera center to the target position
	var direction: Vector2 = (target_position - camera_center).normalized()

	# Find the intersection point with each side of the rectangle
	var intersections: Array[Vector2] = [
		_get_line_intersection(camera_center, direction, top_left, Vector2(bottom_right.x, top_left.y)),                    # Top
		_get_line_intersection(camera_center, direction, Vector2(bottom_right.x, top_left.y), bottom_right),                # Right
		_get_line_intersection(camera_center, direction, Vector2(top_left.x, bottom_right.y), bottom_right),                # Bottom
		_get_line_intersection(camera_center, direction, top_left, Vector2(top_left.x, bottom_right.y))                     # Left
	]

	# Return the first valid intersection point
	for intersection: Vector2 in intersections:
		if intersection != null:
			return intersection
	return camera_center  # Fallback to camera center if no intersection is found


func _get_line_intersection(origin: Vector2, direction: Vector2, line_start: Vector2, line_end: Vector2) -> Vector2:
	# Calculate the intersection between a ray and a line segment
	var line_dir: Vector2 = line_end - line_start
	var det: float = direction.x * line_dir.y - direction.y * line_dir.x
	if abs(det) < 0.0001:
		return origin  # Lines are parallel, return the ray origin as fallback

	var t: float = ((line_start.x - origin.x) * line_dir.y - (line_start.y - origin.y) * line_dir.x) / det
	var u: float = ((line_start.x - origin.x) * direction.y - (line_start.y - origin.y) * direction.x) / det

	if t >= 0 and u >= 0 and u <= 1:
		return origin + direction * t  # Intersection point

	# If no valid intersection, return the ray origin as fallback
	return origin



func get_camera_viewport_rect() -> Rect2:
	var pos: Vector2 = camera.global_position
	var half_size: Vector2 = camera.get_viewport_rect().size * 0.5
	return Rect2(pos - half_size, pos + half_size)
