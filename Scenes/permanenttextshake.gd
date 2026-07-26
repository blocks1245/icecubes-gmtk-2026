extends AnimatedSprite2D

func _process(delta):
	if Settings.textShake:
		play()
	else:
		pause()
