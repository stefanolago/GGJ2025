extends Weapon

class_name BossfightFinger

@onready var hit_detect_area: Area2D = $HitDetectArea

@export var hit_cooldown: float = 0.1
@export var hit_damage: float = 0.1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
		query.position = get_global_mouse_position()
		query.collision_mask = hit_detect_area.collision_mask
		var result: Array[Dictionary] = space_state.intersect_point(query)
		if result:
			for collision: Dictionary in result:
				if collision.collider is BossAttack:
					@warning_ignore("unsafe_cast")
					(collision.collider as BossAttack).hit_bubble(self, hit_damage)
				elif collision.collider is BossBubble:
					@warning_ignore("unsafe_cast")
					(collision.collider as BossBubble).hit_bubble(self, hit_damage)


