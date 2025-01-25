extends Node

signal player_damage_bossfight
signal player_damage_phase_one
signal boss_killed
signal player_damage(health: float, damage_location: Vector2)

const HEALT: float = 10.0

var game_over_scene: PackedScene = preload("res://game/levels/ending_gameover.tscn")
var game_over_playing: bool = false
var all_bubbles: Array = []
var bubbles_popped: int = 0

enum GamePhase{
	PHASE_ONE,
	BOSS_FIGHT
}

var game_phase: GamePhase
var player_health_phase_one: float
var player_health_bossfight: float


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
			_healt_changed(player_health_phase_one, damage_location, _end_phase_one)

		GamePhase.BOSS_FIGHT:
			player_health_bossfight -= damage
			_healt_changed(player_health_bossfight, damage_location, _game_over)


func _healt_changed(healt: float, damage_location: Vector2, death_callable: Callable) -> void: 
	player_damage.emit(healt, damage_location)
	if healt <= 0:
		death_callable.call()


func _ready() -> void:
	reset_stats()

func _end_phase_one() -> void:
	game_phase = GamePhase.BOSS_FIGHT
	#TODO

func _game_over() -> void:
	if not game_over_playing:
		game_over_playing = true
		TransitionLayer.change_scene(game_over_scene)


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
