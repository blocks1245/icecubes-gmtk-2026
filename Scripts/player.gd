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

	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#player state machine
	StateMachine()
	
	#move the player
	move_and_slide()

#Change move direction when hitting wall
func InvertMoveDirection():
	match direction:
		LEFT:
			direction = RIGHT
		RIGHT:
			direction = LEFT

#Defines player states, if ur confused with how something works, start from states.STATE_RUNNING 
#and follow what movement should be done and you'll see how it works
func StateMachine():
	match playerstate:
		states.STATE_RUNNING:
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
			velocity.x = direction * SPEED
			
			if is_on_floor() and is_on_wall():
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
				InvertMoveDirection()
			if is_on_floor():
				playerstate = states.STATE_RUNNING
				InvertMoveDirection()
				
		states.STATE_WALLJUMPED:
			if is_on_floor():
				playerstate = states.STATE_RUNNING
			elif is_on_wall():
				playerstate = states.STATE_WALLCLINGING
			velocity.x = direction * SPEED
				
		states.STATE_WALLRUNNING:
			velocity.y = JUMP_VELOCITY
			playerstate = states.STATE_FALLING
