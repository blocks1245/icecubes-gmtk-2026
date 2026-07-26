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
	{ # Level 0
		"Jump" : 99,
		"Dash" : 99,
		"Slide" : 99
	},
	{ # Level 1
		"Jump" : 25,
		"Dash" : 10,
		"Slide" : 0
	}
]

## VARIABLES

var currentLevel: int = 0 # Index of the current selected level
var winCondition: bool = false
