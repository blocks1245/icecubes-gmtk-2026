extends Node
# Stores information on the current level and configuration of all levels

## CONSTANTS

# Array of scenes for levels in order
const LEVEL_SCENES: Array = [
	"res://Scenes/levels/level1.tscn",
	"res://Scenes/levelbase.tscn"
]

# Array of dictionaries containing the number of allowed moves in each level
const LEVEL_ABILITIES: Array = [
	{ # Level 0
		"Jump" : 20,
		"Dash" : 0,
		"Slide" : 0
	},
	{ # Level 1
		"Jump" : 0,
		"Dash" : 0,
		"Slide" : 10000000
	}
]

## VARIABLES

var currentLevel: int = 0 # Index of the current selected level
var winCondition: bool = false
