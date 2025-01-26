extends BubbleHumorState

var going_towards_bubble: Bubble = null
var going_towards_zone: Marker2D = null
var movement_speed: float = 1200.0
var start_merge_distance_squared: float = 53000.0
# max time before the bubble starts to revolt alone
var max_time_before_revolt: float = 4.0

func enter() -> void:
	super()
	bubble.sprite.set_face_mood("angry")

	# add a collision layer to the bubble so that it is detected as an unattached bubble
	bubble.set_collision_with_unattached_bubbles(true)
	bubble.body_anim_player.play("Squash")


func physics_update(delta: float) -> void:
	super(delta)

	max_time_before_revolt -= delta
	if bubble.started_revolting or max_time_before_revolt < 0.0:
		bubble.started_revolting = true
		transition.emit("Revolting")

	if not bubble.is_group_leader:
		return
	
	# check if the last collision was with an already revolting bubble
	var last_slide_collision: KinematicCollision2D = bubble.get_last_slide_collision()
	if last_slide_collision:
		var last_collision_collider: Object = last_slide_collision.get_collider()
		if last_collision_collider is Bubble and (last_collision_collider as Bubble).started_revolting:
			bubble.started_revolting = true
			return


	if going_towards_bubble and going_towards_bubble.is_group_leader:
		# check if the bubble is near enough to start a 
		# merge procedure
		var distance: float = bubble.global_position.distance_squared_to(going_towards_bubble.global_position)
		if distance < start_merge_distance_squared:
			# only one merge function should be called, I determine an arbitrary
			# reason (in this case the bubble with the lowest RID) and that one starts
			# the merge
			if bubble.get_rid() < going_towards_bubble.get_rid():
				bubble.merge_with_bubble(going_towards_bubble)
				going_towards_bubble = null
		else:
			bubble.velocity = bubble.global_position.direction_to(going_towards_bubble.global_position) * movement_speed
	else:
		# check if there is a nearby bubble that is not still attached to the bubblewrap
		# and is not running away
		# if there is, go to that bubble
		var bubbles: Array = bubble.nearby_unattached_bubble_area.get_overlapping_bodies()
		# check for the closest bubble
		var closest_bubble: Bubble = null
		var closest_distance: float = INF
		for bubble_to_check: Bubble in bubbles:
			if bubble_to_check != bubble and bubble_to_check.is_group_leader:
				var distance: float = bubble.global_position.distance_squared_to(bubble_to_check.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_bubble = bubble_to_check
			
		# if there is a closest bubble, go to it, otherwise go to the nearest group up zone
		if closest_bubble:
			going_towards_bubble = closest_bubble
		else:
			# keep going towards the group up zone if there is one already going towards
			# otherwise go to the nearest group up zone
			if going_towards_zone:
				bubble.velocity = bubble.global_position.direction_to(going_towards_zone.global_position) * movement_speed
			else:
				# if there is no nearby bubble, go to the nearest group up zone
				var zones: Array = get_tree().get_nodes_in_group("group_up_zones")
				var closest_zone: Marker2D = null
				var closest_zone_distance: float = INF
				for zone: Marker2D in zones:
					var distance: float = bubble.global_position.distance_squared_to(zone.global_position)
					if distance < closest_zone_distance:
						closest_zone_distance = distance
						closest_zone = zone
				if closest_zone:
					going_towards_zone = closest_zone
				else:
					push_warning("No group up zones found")
					# use a default zone if no group up zones are found
					going_towards_zone = Marker2D.new()
					going_towards_zone.global_position = Vector2(0, 0)
					
