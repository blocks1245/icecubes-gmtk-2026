extends Control
# The main menu!

## VARIABLES

@onready var level1 = preload("res://Scenes/levels/level1.tscn")
@onready var level2 = preload("res://Scenes/levels/level4.tscn")

@onready var credits: Control = $Credits
@onready var title_card: VSplitContainer = $CenterContainer/TitleCard
@onready var level_select: HSplitContainer = $CenterContainer/LevelSelect
@onready var settings: VSplitContainer = $CenterContainer/Settings
@onready var music: AudioStreamPlayer = $music
@onready var title_music: AudioStreamPlayer = $TitleMusic
@onready var animation_player: AnimationPlayer = $Credits/AnimationPlayer
@onready var title_art: Sprite2D = $Sprite2D
@onready var win: CenterContainer = $Win
@onready var color_rect: ColorRect = $ColorRect
@onready var baby: Sprite2D = $Credits/Baby
@onready var animated_sprite_2d_2: AnimatedSprite2D = $Credits/Control/AnimatedSprite2D2
@onready var animated_sprite_2d: AnimatedSprite2D = $Credits/Control/AnimatedSprite2D

## FUNCTIONS

func _ready() -> void:
	animation_player.play("RESET")
	baby.modulate.a = 0
	title_music.play()
	animated_sprite_2d_2.flip_h = true
	
	animated_sprite_2d.play("dance")
	animated_sprite_2d_2.play("default")
	
	if LevelConfig.winCondition:
		title_card.visible = false
		title_art.visible = false
		win.visible = true
		

func open_level(level: int) -> void: # Switches to a desired scene
	LevelConfig.currentLevel = level # Sets the current level value to the desired index
	get_tree().change_scene_to_packed(LevelConfig.PRELOADED_LEVEL_SCENES[LevelConfig.currentLevel]) # Switches to the desired index

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
	title_music.stop()
	music.play()
	title_card.visible = false
	win.visible = false
	
	credits.visible = true
	animation_player.play("credits")

#TODO: MAKE OUTRO CLEANER
func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_return_pressed() -> void:
	settings.visible = false
	credits.visible = false
	level_select.visible = false
	win.visible = false
	
	animation_player.stop()
	color_rect.visible = false
	music.stop()
	title_music.playing = true
	
	
	title_card.visible = true
	title_art.visible = true

func _on_title_music_finished() -> void:
	title_music.play()

func _on_level_1_pressed() -> void:
	open_level(0) # Hardcoded index because I don't think it's worth doing anything else

func _on_level_2_pressed() -> void:
	open_level(1)

func _on_level_3_pressed() -> void:
	open_level(2)

func _on_level_4_pressed() -> void:
	open_level(3)

func _on_level_5_pressed() -> void:
	open_level(4)
