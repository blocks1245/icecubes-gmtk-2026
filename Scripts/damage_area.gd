extends Area2D
class_name damage_area

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

#generic damage area, can be modified

##DAMAGE AREA SIZE
@export var size: Vector2

func _ready() -> void:
	collision_shape_2d.size = size

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Signals.KillPlayer.emit()
