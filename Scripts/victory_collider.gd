extends Node2D
var starttime


var canswap = true

@export var nextLevel: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.connect("body_entered", Callable(self, "WinLevel"))
	starttime = Time.get_ticks_msec()
	if nextLevel is not PackedScene:
		canswap = false
		printerr("NODE " + str(self) + " HAS NO NEXTLEVEL CHOSEN")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func WinLevel(_body: Node2D):
	Signals.WinLevel.emit(self)
