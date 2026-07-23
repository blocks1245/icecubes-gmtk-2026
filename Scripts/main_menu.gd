extends Control

var level1 = "res://Scenes/level.tscn"


@onready var title_card: VSplitContainer = $TitleCard
@onready var level_select: VSplitContainer = $LevelSelect
@onready var settings: VSplitContainer = $Settings
@onready var credits: VSplitContainer = $Credits


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
	get_tree().change_scene_to_file(level1)


func _on_return_pressed() -> void:
	settings.visible = false
	credits.visible = false
	level_select.visible = false
	title_card.visible = true
	
