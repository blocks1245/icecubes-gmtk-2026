extends CharacterBody2D


var direction: int #player direction

enum states {
	STATE_RUNNING,
	STATE_FALLING,
	STATE_WALLCLINGING,
	STATE_WALLJUMPED,
	STATE_WALLRUNNING
}

var playerstate: int
#which direction (const for clarity)
const LEFT = -1
const RIGHT = 1

#movement consts
const SPEED = 450.0
const JUMP_VELOCITY = -600.0
const WALLJUMP_VELOCITY = -300

#processed once on start of scene
func _ready() -> void:
	playerstate = states.STATE_RUNNING
	direction = RIGHT

#processed every physics frame (every frame)
func _physics_process(delta: float) -> void:

	#handles movement for player
	HandleMovement(delta)
	
	#move the player
	move_and_slide()

	
func HandleMovement(delta: float) -> void:
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	StateMachine()
	
#invert jump height if falling cuz it feels better
func InvertJumpHeight():
	match direction:
		LEFT:
			direction = RIGHT
		RIGHT:
			direction = LEFT


#TODO: fix direction not being accurate sometimes
func StateMachine():
	match playerstate:
		states.STATE_RUNNING:
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
			velocity.x = direction * SPEED
			
			if is_on_floor() and is_on_wall():
				InvertJumpHeight()
				playerstate = states.STATE_WALLRUNNING
			elif !is_on_floor() and is_on_wall():
				playerstate = states.STATE_WALLCLINGING
			
		states.STATE_FALLING:
			if is_on_floor():
				playerstate = states.STATE_RUNNING
			elif is_on_wall():
				playerstate = states.STATE_WALLCLINGING
				
		states.STATE_WALLCLINGING:
			if !is_on_wall():
				playerstate = states.STATE_RUNNING
			if Input.is_action_just_pressed("ui_accept"):
				playerstate = states.STATE_WALLJUMPED
				velocity.y = WALLJUMP_VELOCITY
				InvertJumpHeight()
				
		states.STATE_WALLJUMPED:
			if is_on_floor():
				playerstate = states.STATE_RUNNING
			elif is_on_wall():
				playerstate = states.STATE_WALLCLINGING
			velocity.x = direction * SPEED
				
		states.STATE_WALLRUNNING:
			velocity.y = JUMP_VELOCITY
			playerstate = states.STATE_FALLING
