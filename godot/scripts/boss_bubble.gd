extends Node2D

class_name BossBubble

const max_health: float = 10.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer

@export var attack_mine_scene: PackedScene
@export var ending_scene: PackedScene

var health: float
var speed: float = 100.0
var boss_started: bool = false
var first_hit: bool = true
var dialogic_playing: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	path_follow.progress = 0
	Dialogic.timeline_ended.connect(_dialogue_ended)
	Dialogic.start("bossfight")

func start_boss() -> void:
	anim_player.play("begin_fight")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if boss_started:
		path_follow.progress += speed * delta
		collision_shape.global_position = path_follow.global_position

func hit_bubble(_weapon: Node2D, damage: float) -> void:
	if first_hit and boss_started == false and dialogic_playing == false:
		first_hit = false
		anim_player.play("begin_fight")
	if boss_started:
		health -= damage
		anim_player.play("hit")
		if health <= 0:
			_stop_bossfight()
			pass

func _dialogue_ended() -> void:
	await get_tree().create_timer(1).timeout
	dialogic_playing = false

func _start_bossfight() -> void:
	boss_started = true
	attack_timer.start()

func _stop_bossfight() -> void:
	boss_started = false
	attack_timer.stop()

func _attack() -> void:
	var boss_position: Vector2 = path_follow.global_position
	var mine_instance: StaticBody2D = attack_mine_scene.instantiate()
	mine_instance.global_position = boss_position
	get_tree().root.add_child(mine_instance)
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "begin_fight":
		_start_bossfight()

func _on_attack_timer_timeout() -> void:
	_attack()
