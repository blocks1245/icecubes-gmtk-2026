extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var game_camera: Camera2D = $GameCamera
@onready var fade: AnimationPlayer = $Fade

var nextlevel: PackedScene

const CENTER = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.connect("KillPlayer", Callable(self, "LoseGame"))
	Signals.connect("WinLevel", Callable(self, "WinGame"))
	
	get_tree().paused = true
	fade.play("Fade_from_black")
	await fade.animation_finished
	
	game_camera.position.x = ProjectSettings.get_setting("display/window/size/viewport_width") / 2
	fade.play("countdown")
	await fade.animation_finished
	get_tree().paused = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if player.position.y < game_camera.position.y - 100:
		game_camera.position.y -= (game_camera.position.y - 100) - player.position.y
		
	elif player.position.y > game_camera.position.y + 100:
		game_camera.position.y +=  player.position.y - (game_camera.position.y + 100) 
		
func LoseGame():
	$GameCamera/Loss.visible = true
	get_tree().paused = true
	
func WinGame(node: Node2D):
	$GameCamera/Victory/vic.text = "YOU WIN\n level beaten in " + str(float((Time.get_ticks_msec() - node.starttime))/1000) + " seconds"
	$GameCamera/Victory/vic.visible = true
	$GameCamera/Victory.visible = true
	player.playerstate = player.STATE_START
	nextlevel = node.nextLevel
	print(nextlevel)



func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(get_tree().root.get_path())


func _on_mainmenu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_next_level_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(nextlevel)
