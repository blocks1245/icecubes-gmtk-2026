class_name Digit

extends AnimatedSprite2D

func changeDisplay(num: String) -> void:
	self.play(num, 0)

func shiver() -> void:
	self.play(self.animation, 1)

# no longer in use, keeping for now
