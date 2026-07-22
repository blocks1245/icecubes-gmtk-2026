extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var game_camera: Camera2D = $GameCamera

const CENTER = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_camera.position.x = ProjectSettings.get_setting("display/window/size/viewport_width") / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if player.position.y < game_camera.position.y - 100:
		game_camera.position.y -= (game_camera.position.y - 100) - player.position.y
		
	elif player.position.y > game_camera.position.y + 100:
		game_camera.position.y +=  player.position.y - (game_camera.position.y + 100) 
	
