extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.connect("body_entered", Callable(self, "WinLevel"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func WinLevel(_body: Node2D):
	$Label.visible = true
	get_tree().paused = true
