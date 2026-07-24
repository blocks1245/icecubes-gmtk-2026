extends Node2D
# Manages what actually happens inside a level

## CONSTANTS

const CENTER = 0
const CAMERA_PADDING = 100

## VARIABLES

# References to other nodes
@onready var player: CharacterBody2D = $Player
@onready var game_camera: Camera2D = $GameCamera
@onready var fade: AnimationPlayer = $Fade

var nextlevel: PackedScene # The next scene

## FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signals
	Signals.connect("KillPlayer", Callable(self, "LoseGame"))
	Signals.connect("WinLevel", Callable(self, "WinGame"))
	
	get_tree().paused = true # Pause the scecne tree
	
	fade.play("Fade_from_black") # Fade in from black
	await fade.animation_finished # Wait for the animation to finish
	
	# Center the camera horizontally (do we want it to follow horizontally instead?)
	game_camera.position.x = ProjectSettings.get_setting("display/window/size/viewport_width") / 2
	
	fade.play("countdown") # Play countdown animation
	await fade.animation_finished # Wait for it to finish
	
	get_tree().paused = false # Unpause the scene tree

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Move the camera according to the player's vertical position
	if player.position.y < game_camera.position.y - CAMERA_PADDING:
		game_camera.position.y -= (game_camera.position.y - CAMERA_PADDING) - player.position.y
		
	elif player.position.y > game_camera.position.y + CAMERA_PADDING:
		game_camera.position.y +=  player.position.y - (game_camera.position.y + CAMERA_PADDING) 

func LoseGame(): # On game loss
	$GameCamera/Loss.visible = true # Make loss GUI visible
	player.playerstate = player.STATE_START # Set the player into the starting state
	# You're placed in the start state so this shouldn't be necessary, you can't do anything in that anyways lol
	# Disabling it will keep animations running smoothly and stuff(?) although it's 9 so if I'm being dumb lmk
	#get_tree().paused = true # Pause the scene tree

func WinGame(node: Node2D): # On game win
	# Output win UI
	$GameCamera/Victory/vic.text = "YOU WIN\n level " + str(LevelConfig.currentLevel) + " beaten in " + str(float((Time.get_ticks_msec() - node.starttime))/1000) + " seconds"
	$GameCamera/Victory/vic.visible = true
	$GameCamera/Victory.visible = true
	player.playerstate = player.STATE_START # Set the player into the starting state
	print("wawa I'm in starting state")
	nextlevel = node.nextLevel # Get the next available level

func _on_retry_pressed() -> void: # When pressing retry
	#get_tree().paused = false # Unpause the scene
	get_tree().change_scene_to_file(LevelConfig.LEVEL_SCENES[LevelConfig.currentLevel]) # Reload the current level

func _on_mainmenu_pressed() -> void: # When pressing main menu
	#get_tree().paused = false # Unpause the scene
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn") # Load the main menu

func _on_next_level_pressed() -> void: # When pressing next level
	LevelConfig.currentLevel += 1 # Increment the level index
	#get_tree().paused = false # Unpause the scene
	# I would change this to use LevelConfig but I don't wanna break anything lol
	get_tree().change_scene_to_packed(nextlevel) 
