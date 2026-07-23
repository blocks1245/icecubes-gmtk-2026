extends CharacterBody2D

#preload dash node path on start of scene
@onready var dash_duration: Timer = $DashDuration
@onready var coyote_jump: Timer = $CoyoteJump
@onready var dash_cd: Timer = $DashCD

## CONSTANTS

# Player physics states
enum {
	STATE_START,
	STATE_RUNNING,
	STATE_WALLCLINGING,
	STATE_DASHING,
	STATE_SLIDING
}

# Current movement direction constants
const LEFT: int = -1
const RIGHT: int = 1

# Movement magnitude constants
const SPEED: float = 300.0
const JUMP_VELOCITY: float = -600.0
const WALLJUMP_VELOCITY: float = -450.0
const DASH_SPEED: float = 900.0

## VARIABLES

var playerstate: int = STATE_START # Current physics state of the player, defaulted to running
var direction: int = RIGHT # Current direction of movement, defaulted right
var gravitymod: float = 1.0 # Current modifier on gravity, defaulted to neutral

## FUNCTIONS

# Note: I deleted the intial run function, and just defined the default values at initialization.
# GDScript will let us so it's just one less way to make a dumb mistake and crash everything lmao

func CanJump() -> bool:
	if is_on_floor() or coyote_jump.time_left > 0:
		return true
	else:
		return false

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	$dieandstartsheet.visible = true
	$dieandstartsheet.play("Spawn")
	await $dieandstartsheet.animation_finished
	$playersheet.visible = true
	await get_tree().create_timer(2.5).timeout
	$playersheet.play("default")
	playerstate = STATE_RUNNING
	
# Runs every physics frame
func _physics_process(delta: float) -> void:
	StateMachine() # Determine the physics state of the player
	
	if not is_on_floor(): # If in the air
		velocity += get_gravity() * delta * gravitymod # Apply velocity from the acceleration of gravity\
		# Multiplied by the number of frames in this physics frame, and the gravity modifier
		if coyote_jump.is_stopped():
			coyote_jump.start()
	
	move_and_slide() # Move the player based on determined velocity

# Swaps the current direction of movement
func InvertMoveDirection() -> void:
	match direction:
		LEFT:
			direction = RIGHT
			$playersheet.flip_h = false
		RIGHT:
			direction = LEFT
			$playersheet.flip_h = true
		_: # Reset back to right if anything goes wrong
			direction = RIGHT

#Defines player states, if ur confused with how something works, start from STATE_RUNNING 
#and follow what movement should be done and you'll see how it works
func StateMachine() -> void:
	match playerstate: # Match the current player physics state to one of the following options
		STATE_START:
			pass
			
		STATE_RUNNING: # Moving horizontally state (the default!)
			gravitymod = 1.0 # Reset gravity to normal
			
			velocity.x = direction * SPEED # Set horizontal velocity
			
			if CanJump() and Input.is_action_just_pressed("Jump"): # If jumping
				velocity.y = JUMP_VELOCITY # Set vertical velocity
			
			if Input.is_action_just_pressed("Dash") and dash_cd.is_stopped(): # If dashing
				playerstate = STATE_DASHING # Set state to dashing
				dash_duration.start() # Start the dash timer
				
			elif Input.is_action_just_pressed("Slide"):
				playerstate = STATE_SLIDING
			
			if is_on_wall(): # If touching the wall
				playerstate = STATE_WALLCLINGING # Enter wallclinging state
				if is_on_floor(): # If ALSO on the floor
					velocity.y = JUMP_VELOCITY # Set vertical velocity to jump
				
		STATE_WALLCLINGING: # Wallclinging state
			if velocity.y > 0: # If heading DOWN
				gravitymod = 0.2 # Reduce gravity (like mantis claw)
			else: # If heading UP
				gravitymod = 1.0 # Leave gravity at base
			
			if Input.is_action_just_pressed("Jump"): # If jump is pressed
				playerstate = STATE_RUNNING # Reset state to running
				velocity.y = WALLJUMP_VELOCITY # Set vertical velocity to jump
				InvertMoveDirection() # Invert movement direction (to jump AWAY from the wall)
			
			elif Input.is_action_just_pressed("Dash") and dash_cd.time_left > 0: # If dashing
				playerstate = STATE_DASHING # Set state to dashing
				InvertMoveDirection() # Invert movement direction (to dash AWAY from the wall)
				dash_duration.start() # Start the dash duration timer
			
			if !is_on_wall(): # If no longer on a wall
				playerstate = STATE_RUNNING # Reset to running state 
				# (prevents walljumping after flying up above a wall!)
			
			if is_on_floor(): # If on the floor
				playerstate = STATE_RUNNING # Reset to running state
				InvertMoveDirection() # Invert movement direction (so you don't run back into the wall)
			
		STATE_DASHING: # Dashing state
			gravitymod = 0.0 # Disable acceleration from gravity
			velocity.y = 0 # Freeze vertical acceleration
			
			velocity.x = DASH_SPEED * direction # Set horizontal dash velocity
			
			if dash_duration.time_left == 0:
				dash_cd.start()
				if is_on_wall(): # When the dash duration runs out
					velocity.x = SPEED * direction # Set the horizontal velocity back to normal
					playerstate = STATE_WALLCLINGING # Reset to running state
				else:
					playerstate = STATE_RUNNING
		
		STATE_SLIDING:
			if !Input.is_action_pressed("Slide") and !Input.is_action_just_pressed("Slide"):
				scale.y = 1
				playerstate = STATE_RUNNING
				return
			scale.y = 0.5
			if is_on_floor():
				velocity.x = SPEED * direction * 1.5
			elif not is_on_floor():
				velocity.y = 1000
			if is_on_wall() and Input.is_action_just_released("Slide"):
				InvertMoveDirection()
				scale.y = 1
				playerstate = STATE_RUNNING
				
		
		_: # If the playerstate isn't here, send an error message
			printerr("playerstate \"", playerstate, "\" not found!")
