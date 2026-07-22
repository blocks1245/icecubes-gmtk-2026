extends Node2D
var starttime

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.connect("body_entered", Callable(self, "WinLevel"))
	starttime = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func WinLevel(_body: Node2D):
	$Label.text = "YOU WIN\n level beaten in " + str(float((Time.get_ticks_msec() - starttime)/1000)) + " seconds"
	$Label.visible = true
	get_tree().paused = true
