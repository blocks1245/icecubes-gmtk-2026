extends CanvasLayer

const HEIGHT_OFFSET: int = 6
const WIDTH_OFFSET: int = 12

@onready var jump: Panel = $Jump
@onready var dash: Panel = $Dash
@onready var slide: Panel = $Slide
@onready var digit: AnimatedSprite2D = $digit

@onready var clock_1: AudioStreamPlayer = $Clock1
@onready var clock_2: AudioStreamPlayer = $Clock2

var clockToggle: bool = false

var jumpDigits: Array = []
var dashDigits: Array = []
var slideDigits: Array = []

func _ready() -> void:
	Signals.connect("UpdateJump", Callable(self, "updateJump"))
	Signals.connect("UpdateDash", Callable(self, "updateDash"))
	Signals.connect("UpdateSlide", Callable(self, "updateSlide"))

func populateDigitalDisplay(number: int, panel: Panel) -> Array:
	var numString: String = str(number)
	var digits: Array = []
	
	var digitHeight: int = panel.size.y / 2 - HEIGHT_OFFSET
	
	for i in numString.length():
		var d: AnimatedSprite2D = digit.duplicate()
		panel.add_child(d)
		changeDisplay(d, numString[i])
		d.visible = true
		
		# Temporary position code
		d.position.x += panel.size.x / 2
		d.position.y += digitHeight
		
		digits.append(d)
	
	var width: int = panel.size.x - (2 * WIDTH_OFFSET)
	var cellWidth: int = width / digits.size()
	
	for i in digits.size():
		digits[i].position.x = WIDTH_OFFSET + (cellWidth * i) + (cellWidth / 2)
		shiver(digits[i], panel)
	
	ticktock()
	return digits

func changeDisplay(d: AnimatedSprite2D, num: String) -> void:
	d.play(num, 0)

func shiver(d: AnimatedSprite2D, p: Panel) -> void:
	if Settings.textShake:
		d.play(d.animation)
		p.get_node("animator").play()

func ticktock() -> void:
	if clockToggle:
		clockToggle = false
		clock_2.play()
	else:
		clockToggle = true
		clock_1.play()

func cleanArray(arr: Array):
	if arr.size() > 0:
		for i in arr:
			i.queue_free()

func updateJump(value: int):
	cleanArray(jumpDigits)
	jumpDigits = populateDigitalDisplay(value, jump)

func updateDash(value: int):
	cleanArray(dashDigits)
	dashDigits = populateDigitalDisplay(value, dash)

func updateSlide(value: int):
	cleanArray(slideDigits)
	slideDigits = populateDigitalDisplay(value, slide)
