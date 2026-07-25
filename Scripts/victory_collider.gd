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

func WinLevel(body: Node2D):
	if body.is_in_group("Player"):
		Signals.WinLevel.emit(self)
