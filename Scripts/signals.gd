extends Node
# Stores and manages signals

signal KillPlayer
signal StartLevel
signal WinLevel(node: Node2D)

signal UpdateJump(remaining: int)
signal UpdateDash(remaining: int)
signal UpdateSlide(remaining: int)
