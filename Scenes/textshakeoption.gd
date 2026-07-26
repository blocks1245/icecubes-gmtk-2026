extends Button

@onready var animator : AnimatedSprite2D = $animator
@onready var animator_2: AnimatedSprite2D = $animator2

func _process(delta):
	if (is_hovered() and Settings.textShake):
		animator.play()
		animator_2.play()
	elif (animator.is_playing()):
		animator.pause()
		animator_2.pause()

func _on_pressed() -> void:
	if Settings.textShake:
		animator_2.animation = "off"
		Settings.textShake = false
	else:
		animator_2.animation = "on"
		Settings.textShake = true
