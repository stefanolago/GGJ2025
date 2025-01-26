extends Weapon

class_name Finger

@onready var hit_detect_area: Area2D = $HitDetectArea

@export var hit_damage: float = 5.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
		query.position = get_global_mouse_position()
		query.collision_mask = hit_detect_area.collision_mask
		var result: Array[Dictionary] = space_state.intersect_point(query)
		if result:
			for collision: Dictionary in result:
				if collision.collider is Bubble:
					var bubble: Bubble = collision.collider
					bubble.hit_bubble(self, hit_damage)


