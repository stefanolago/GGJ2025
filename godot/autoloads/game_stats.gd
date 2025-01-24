extends Node

signal player_damage_bossfight

var player_health_bossfight: float:
	set(value):
		player_health_bossfight = value
		player_damage_bossfight.emit()
var cazzi_vari: String


## usare GameSettings.difficulty_mult come multiplicatore della difficolta, default 1
## ricordandosi di fare un ceil() per arrotondare
## oppure usare GameSettings.difficulty_setting per settare valori custom

## ex:
# boss_health = ceil(50 * GameSettings.difficulty_mult)
## or
# if GameSettings.difficulty_setting = "Hard":
#     boss_health = 75

func take_damage_bossfight(damage: float) -> void:
	player_health_bossfight -= damage

func _ready() -> void:
	reset_stats()

# settare qui i valori iniziali
func reset_stats() -> void:
	player_health_bossfight = 10
	cazzi_vari = "cazzi vari"

# save the game settings into a config file, saved locally
func save_stats() -> void:
	print ("SAVING STATS")
	var stats:ConfigFile = ConfigFile.new()
	
	stats.set_value("Stats", "player_health", player_health_bossfight)
	stats.set_value("Stats", "cazzi_vari", cazzi_vari)
	
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
	cazzi_vari = stats.get_value("Stats", "cazzi_vari")
