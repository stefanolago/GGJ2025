extends Node

@warning_ignore("unused_signal")
signal player_damage_bossfight
@warning_ignore("unused_signal")
signal player_damage_phase_one
@warning_ignore("unused_signal")
signal boss_killed
signal player_damage(health: float, damage_location: Vector2)
signal player_killed_bossfight

var boss_scene: PackedScene = preload("res://game/levels/tribunal.tscn")

const HEALT: float = 10.0

var player_revived_bossfight: bool = false
var all_bubbles: Array = []
var bubbles_popped: int = 0
var boss_instance: BossBubble

enum GamePhase{
	PHASE_ONE,
	BOSS_FIGHT
}

var game_phase: GamePhase
var player_health_phase_one: float
var player_health_bossfight: float
var revolt_started: bool = false:
	set(value):
		revolt_started = value
		if revolt_started:	
			(GlobalAudio as AudioWrapper).switch_to_clip("phase_one_song", "bubble_song_2")




## usare GameSettings.difficulty_mult come multiplicatore della difficolta, default 1
## ricordandosi di fare un ceil() per arrotondare
## oppure usare GameSettings.difficulty_setting per settare valori custom

## ex:
# boss_health = ceil(50 * GameSettings.difficulty_mult)
## or
# if GameSettings.difficulty_setting = "Hard":
#     boss_health = 75
func take_damage(damage: float, damage_location: Vector2) -> void:
	match game_phase:
		GamePhase.PHASE_ONE:
			player_health_phase_one -= damage
			_health_changed(player_health_phase_one, damage_location, _end_phase_one)

		GamePhase.BOSS_FIGHT:
			if not player_revived_bossfight:
				player_health_bossfight -= damage
				_health_changed(player_health_bossfight, damage_location, _game_over_bossfight)


func _health_changed(healt: float, damage_location: Vector2, death_callable: Callable) -> void: 
	player_damage.emit(healt, damage_location)
	if healt <= 0:
		death_callable.call()


func _ready() -> void:
	reset_stats()

func _end_phase_one() -> void:
	TransitionLayer.change_scene(boss_scene)
	game_phase = GamePhase.BOSS_FIGHT

func _game_over_bossfight() -> void:
	if not player_revived_bossfight:
		player_revived_bossfight = true
		player_health_bossfight = HEALT
		player_killed_bossfight.emit()

# Set here all the game stats
func reset_stats() -> void:
	game_phase = GamePhase.PHASE_ONE
	player_health_phase_one = HEALT
	player_health_bossfight = HEALT


# Save the game settings into a config file, saved locally
func save_stats() -> void:
	print ("SAVING STATS")
	var stats:ConfigFile = ConfigFile.new()
	
	stats.set_value("Stats", "player_health", player_health_bossfight)
	
	stats.save("user://stats_data.cfg")


# Load the game stats from the local config file
func load_stats() -> void:
	print ("LOADING SETTINGS")
	var stats:ConfigFile = ConfigFile.new()
	
	var f:Error = stats.load("user://settings_data.cfg")
	if f != OK: # return if the file doesn't exist
		print ("STATS CONFIG FILE DOES NOT EXISTS")
		return

	# set all the saved variables
	player_health_bossfight = stats.get_value("Stats", "player_health")
