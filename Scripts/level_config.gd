extends Node

var currentLevel: int = 0 # Index of the current selected level

# Array of scenes for levels in order
var levelScenes: Array = [
	"res://Scenes/levels/level.tscn",
	"res://Scenes/levels/leveltilemap.tscn"
]

# Array of dictionaries containing valid moves in each level
var levels: Array = [
	{ # Level 0
		"Jump" : 99,
		"Dash" : 99,
		"Slide" : 99
	},
	{ # Level 1
		"Jump" : 0,
		"Dash" : 0,
		"Slide" : 10000000
	}
]
