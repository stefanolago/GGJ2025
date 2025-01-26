extends Node2D

class_name BossBubble

const max_health: float = 20.0
const mines_to_spawn: int = 4
const teleport_attacks: int = 5

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer
@onready var teleport_sprite: Node2D = %Teleport
@onready var judge_wig: Sprite2D = %BubbleWig
@onready var boss_face: AnimatedSprite2D = %Face

@export var attack_mine_scene: PackedScene
@export var ending_gameover: PackedScene
@export var ending_win: PackedScene
@export var attack_cooldown: float = 3.0
@export var finger_weapon: Weapon
@export var machinegun_weapon: Weapon

var health: float
var speed: float = 100.0
var boss_started: bool = false
var first_hit: bool = true
var dialogic_playing: bool = true
var boss_is_alive: bool = true
var bomb_attack_timer: float = 0.8
var bomb_speed_multiplier: float = 1
var round_attack_pattern: Array= [Vector2(0, 150),
								Vector2(0, -150),
								Vector2(130, 75),
								Vector2(130, -75),
								Vector2(-130, 75),
								Vector2(-130, -75)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	path_follow.progress = 0
	attack_timer.wait_time = attack_cooldown
	GameStats.game_phase = GameStats.GamePhase.BOSS_FIGHT
	GameStats.player_killed_bossfight.connect(_player_second_phase)
	Dialogic.timeline_ended.connect(_dialogue_ended)
	Dialogic.signal_event.connect(_dialogic_signal)
	(GlobalAudio as AudioWrapper).fade_in("court_music", 0.1)
	Dialogic.start("bossfight")
	boss_face.play("talk")
	#_start_bossfight()   # DEBUG

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if boss_started:
		path_follow.progress += speed * delta
		collision_shape.global_position = path_follow.global_position


func hit_bubble(_weapon: Node2D, damage: float) -> void:
	if first_hit and boss_started == false and dialogic_playing == false:
		(GlobalAudio as AudioWrapper).play_one_shot("boss_hit")
		(GlobalAudio as AudioWrapper).pause_stream("court_music", true)
		first_hit = false
		dialogic_playing = true
		anim_player.play("first_hit")
		Dialogic.timeline_ended.disconnect(_dialogue_ended)
		await get_tree().create_timer(1).timeout
		Dialogic.timeline_ended.connect(_second_dialogue_ended)
		Dialogic.start("attack")
		boss_face.play("talk")
	if boss_started:
		(GlobalAudio as AudioWrapper).play_one_shot("boss_hit")
		health -= damage
		anim_player.play("hit")
		_check_health()

func _check_health() -> void:
	var health_percentage: float = 100 * float(health)/float(max_health)
	if health_percentage <= 0:
		_stop_bossfight()
		return
	elif health_percentage <= 45:
		speed = 400
		bomb_attack_timer = 0.2
		bomb_speed_multiplier = 2.5
		return
	elif health_percentage <= 75:
		speed = 300
		bomb_attack_timer = 0.4
		attack_cooldown = 1
		bomb_speed_multiplier = 1.85
		return
	elif health_percentage <= 90:
		speed = 200
		bomb_attack_timer = 0.6
		attack_cooldown = 2
		bomb_speed_multiplier = 1.45

func _player_second_phase() -> void:
	print("PLAYER SECOND PHASE")
	finger_weapon.active = false
	machinegun_weapon.active = true
	
### DIALOGUE STUFF ###
func _dialogue_ended() -> void:
	boss_face.play("default")
	await get_tree().create_timer(1).timeout
	dialogic_playing = false

func _second_dialogue_ended() -> void:
	boss_face.play("default")
	dialogic_playing = false
	anim_player.play("begin_fight")
	(GlobalAudio as AudioWrapper).fade_in("boss_music", 0.0)

func _start_bossfight() -> void:
	boss_face.play("default")
	boss_started = true
	attack_timer.start()

func _stop_bossfight() -> void:
	boss_is_alive = false
	boss_started = false
	attack_timer.stop()
	anim_player.play("pop_boss")
	GameStats.boss_killed.emit()
	(GlobalAudio as AudioWrapper).pause_stream("boss_music", true)
	(GlobalAudio as AudioWrapper).play_one_shot("bubble_pop")

func _hammer_hit() -> void:
	anim_player.play("hammer")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "begin_fight":
		_start_bossfight()
	if anim_name == "pop_boss":
		TransitionLayer.change_scene(ending_win)

### COMBAT ###
func _spawn_bomb(bomb_position: Vector2, bomb_health: float) -> void:
	var bomb_instance: BossAttack = attack_mine_scene.instantiate()
	bomb_instance.global_position = bomb_position
	bomb_instance.speed_anim = BossAttack.INITIAL_SPEED_ANIM * bomb_speed_multiplier
	get_tree().root.add_child(bomb_instance)
	bomb_instance.health = bomb_health

func _bomb_attack() -> void:
	for mine_index: int in range(mines_to_spawn):
		if not boss_is_alive:
			return
		var boss_position: Vector2 = path_follow.global_position
		await get_tree().create_timer(bomb_attack_timer).timeout
		_spawn_bomb(boss_position, 0.1)
	_attack_completed()

func _teleport_attack() -> void:
	teleport_sprite.show()
	judge_wig.hide()
	for teleport_index: int in range(teleport_attacks):
		if not boss_is_alive:
			return
		GlobalAudio.play_one_shot("teleport")
		var random_path_ratio: float = randf_range(0.0, 1.0)
		path_follow.progress_ratio = random_path_ratio
		var boss_position: Vector2 = path_follow.global_position
		_spawn_bomb(boss_position, 0.1)
		await get_tree().create_timer(0.3).timeout
	teleport_sprite.hide()
	judge_wig.show()
	_attack_completed()

func _circle_attack() -> void:
	var boss_position: Vector2 = path_follow.global_position
	round_attack_pattern.shuffle()
	for pattern_position: Vector2 in round_attack_pattern:
		if not boss_is_alive:
			return
		var spawn_position: Vector2 = boss_position + pattern_position
		_spawn_bomb(spawn_position, 0.1)
		await get_tree().create_timer(0.05).timeout
	_attack_completed()

func _choose_attack() -> void:
	attack_timer.stop()
	var random_attack: int = randi_range(0,2)
	match random_attack:
		0:
			_bomb_attack()
		1: 
			_teleport_attack()
		2:
			_circle_attack()
		_:
			_bomb_attack()

func _attack_completed() -> void:
	if boss_is_alive:
		attack_timer.start()

func _on_attack_timer_timeout() -> void:
	if boss_is_alive:
		_choose_attack()

func _dialogic_signal(event:String) -> void:
	match event:
		"hammer":
			_hammer_hit()
		"boss_talk_start":
			boss_face.play("talk")
		"boss_talk_stop":
			boss_face.play("default")
