extends CharacterBody2D

class_name Bubble

const speed: int = 300

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var nav_timer: Timer = $NavigationTimer

var is_detached: bool = false

func _physics_process(_delta: float) -> void:
	if is_detached:
		var dir: Vector2 = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = dir * speed
		move_and_slide()

func _make_path() -> void:
	nav_agent.target_position = get_local_mouse_position()

func _on_navigation_timer_timeout() -> void:
	if is_detached:
		_make_path()

func detach() -> void:
	is_detached = true
	nav_timer.start()

func nearby_bubble_popped() -> void:
	pass
