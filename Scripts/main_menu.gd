extends Control
# The main menu!

## VARIABLES

@onready var title_card: VSplitContainer = $TitleCard
@onready var level_select: VSplitContainer = $LevelSelect
@onready var settings: VSplitContainer = $Settings
@onready var credits: VSplitContainer = $Credits

## FUNCTIONS

func open_level(level: int) -> void: # Switches to a desired scene
	LevelConfig.currentLevel = level # Sets the current level value to the desired index
	get_tree().change_scene_to_file(LevelConfig.LEVEL_SCENES[level]) # Switches to the desired index

#TODO: MAKE LEVEL SELECT SCREEN AND SAVE DATA FOR LEVELS BEATEN/TIME TO BEAT
func _on_lvselect_pressed() -> void:
	title_card.visible = false
	level_select.visible = true

#TODO: MAKE SETTINGS AND SAVE DATA FOR SETTINGS
func _on_settings_pressed() -> void:
	title_card.visible = false
	settings.visible = true

#TODO: MAKE CREDITS
func _on_credits_pressed() -> void:
	title_card.visible = false
	credits.visible = true

#TODO: MAKE OUTRO CLEANER
func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_level_1_pressed() -> void:
	open_level(0) # Hardcoded index because I don't think it's worth doing anything else

func _on_return_pressed() -> void:
	settings.visible = false
	credits.visible = false
	level_select.visible = false
	title_card.visible = true
	
