extends Button

@onready var animator : AnimatedSprite2D = $animator

func _process(delta):
	if (is_hovered()):
		animator.play()
	elif (animator.is_playing()):
		animator.pause()
