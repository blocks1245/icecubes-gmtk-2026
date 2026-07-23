extends Node
# Stores information on the current level and configuration of all levels

## CONSTANTS

# Array of scenes for levels in order
const LEVEL_SCENES: Array = [
	"res://Scenes/levels/level.tscn",
	"res://Scenes/levels/leveltilemap.tscn"
]

# Array of dictionaries containing the number of allowed moves in each level
const LEVEL_ABILITIES: Array = [
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

## VARIABLES

var currentLevel: int = 0 # Index of the current selected level
