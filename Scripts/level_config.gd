extends Node
# Stores information on the current level and configuration of all levels

## CONSTANTS

## Array of scenes for levels in order
const LEVEL_SCENES: Array = [
	"res://Scenes/levels/level1.tscn",
	"res://Scenes/levels/level2.tscn",
	"res://Scenes/levels/level3.tscn",
	"res://Scenes/levels/level4.tscn",
	"res://Scenes/levels/level5.tscn"
]
@onready var PRELOADED_LEVEL_SCENES: Array = [
	preload("res://Scenes/levels/level1.tscn"),
	preload("res://Scenes/levels/level2.tscn"),
	preload("res://Scenes/levels/level3.tscn"),
	preload("res://Scenes/levels/level4.tscn"),
	preload("res://Scenes/levels/level5.tscn")
]

# Array of dictionaries containing the number of allowed moves in each level
const LEVEL_ABILITIES: Array = [
	{ # Level 1
		"Jump" : 13,
		"Dash" : 3,
		"Slide" : 0
	},
	{ # Level 2
		"Jump" : 25,
		"Dash" : 10,
		"Slide" : 0
	},
	{ # Level 3
		"Jump" : 20,
		"Dash" : 5,
		"Slide" : 0
	},
	{ # Level 4
		"Jump" : 20,
		"Dash" : 0,
		"Slide" : 0
	},
	{ # Level 5
		"Jump" : 20,
		"Dash" : 0,
		"Slide" : 0
	}
]

## VARIABLES

var currentLevel: int = 0 # Index of the current selected level
var winCondition: bool = false
