extends Node

signal player_damage_bossfight
signal player_damage_phase_one
signal boss_killed

var game_over_scene: PackedScene = preload("res://game/levels/ending_gameover.tscn")
var game_over_playing: bool = false
var all_bubbles: Array = []
var bubbles_popped: int = 0

var player_health_bossfight: float:
	set(value):
		player_health_bossfight = value
		player_damage_bossfight.emit()


## usare GameSettings.difficulty_mult come multiplicatore della difficolta, default 1
## ricordandosi di fare un ceil() per arrotondare
## oppure usare GameSettings.difficulty_setting per settare valori custom

## ex:
# boss_health = ceil(50 * GameSettings.difficulty_mult)
## or
# if GameSettings.difficulty_setting = "Hard":
#     boss_health = 75

func take_damage_phase_one(damage: float, bubble: Bubble) -> void:
	player_damage_phase_one.emit()


func take_damage_bossfight(damage: float) -> void:
	player_health_bossfight -= damage
	if player_health_bossfight <= 0:
		_game_over()

func _ready() -> void:
	reset_stats()

func _game_over() -> void:
	if not game_over_playing:
		game_over_playing = true
		TransitionLayer.change_scene(game_over_scene)

# settare qui i valori iniziali
func reset_stats() -> void:
	player_health_bossfight = 10

# save the game settings into a config file, saved locally
func save_stats() -> void:
	print ("SAVING STATS")
	var stats:ConfigFile = ConfigFile.new()
	
	stats.set_value("Stats", "player_health", player_health_bossfight)
	
	stats.save("user://stats_data.cfg")


# load the game stats from the local config file
func load_stats() -> void:
	print ("LOADING SETTINGS")
	var stats:ConfigFile = ConfigFile.new()
	
	var f:Error = stats.load("user://settings_data.cfg")
	if f != OK: # return if the file doesn't exist
		print ("STATS CONFIG FILE DOES NOT EXISTS")
		return

	# set all the saved variables
	player_health_bossfight = stats.get_value("Stats", "player_health")
