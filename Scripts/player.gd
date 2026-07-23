extends CharacterBody2D

## CONSTANTS

# Player physics states
enum {
	STATE_RUNNING,
	STATE_WALLCLINGING,
	STATE_DASHING
}

# Current movement direction constants
const LEFT = -1
const RIGHT = 1

# Movement magnitude constants
const SPEED = 300
const JUMP_VELOCITY = -600
const WALLJUMP_VELOCITY = -450
const DASH_SPEED = SPEED * 3

# Controls constants (I can maybe remove these? Had them before I made custom input maps lol)
const JUMP_ACTION = "Jump"
const DASH_ACTION = "Dash"

## VARIABLES

var playerstate = STATE_RUNNING # Current physics state of the player, defaulted to running
var direction = RIGHT # Current direction of movement, defaulted right
var gravitymod = 1.0 # Current modifier on gravity, defaulted to neutral

## FUNCTIONS

# Note: I deleted the intial run function, and just defined the default values at initialization.
# GDScript will let us so it's just one less way to make a dumb mistake and crash everything lmao

# Runs every physics frame
func _physics_process(delta: float) -> void:
	StateMachine() # Determine the physics state of the player
	
	if not is_on_floor(): # If in the air
		velocity += get_gravity() * delta * gravitymod # Apply velocity from the acceleration of gravity\
		# Multiplied by the number of frames in this physics frame, and the gravity modifier
	
	move_and_slide() # Move the player based on determined velocity

# Swaps the current direction of movement
func InvertMoveDirection() -> void:
	match direction:
		LEFT:
			direction = RIGHT
		RIGHT:
			direction = LEFT
		_: # Reset back to right if anything goes wrong
			direction = RIGHT

#Defines player states, if ur confused with how something works, start from states.STATE_RUNNING 
#and follow what movement should be done and you'll see how it works
func StateMachine() -> void:
	match playerstate: # Match the current player physics state to one of the following options
		STATE_RUNNING: # Moving horizontally state (the default!)
			gravitymod = 1.0 # Reset gravity to normal
			
			velocity.x = direction * SPEED # Set horizontal velocity
			
			if is_on_floor() and Input.is_action_just_pressed(JUMP_ACTION): # If jumping
				velocity.y = JUMP_VELOCITY # Set vertical velocity
			
			if Input.is_action_just_pressed(DASH_ACTION): # If dashing
				playerstate = STATE_DASHING # Set state to dashing
				$DashDuration.start() # Start the dash timer
			
			if is_on_wall(): # If touching the wall
				playerstate = STATE_WALLCLINGING # Enter wallclinging state
				if is_on_floor(): # If ALSO on the floor
					velocity.y = JUMP_VELOCITY # Set vertical velocity to jump
				
		STATE_WALLCLINGING: # Wallclinging state
			if velocity.y > 0: # If heading DOWN
				gravitymod = 0.2 # Reduce gravity (like mantis claw)
			else: # If heading UP
				gravitymod = 1.0 # Leave gravity at base
			
			if Input.is_action_just_pressed(JUMP_ACTION): # If jump is pressed
				playerstate = STATE_RUNNING # Reset state to running
				velocity.y = WALLJUMP_VELOCITY # Set vertical velocity to jump
				InvertMoveDirection() # Invert movement direction (to jump AWAY from the wall)
			
			elif Input.is_action_just_pressed(DASH_ACTION): # If dashing
				playerstate = STATE_DASHING # Set state to dashing
				InvertMoveDirection() # Invert movement direction (to dash AWAY from the wall)
				$DashDuration.start() # Start the dash duration timer
			
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
			
			if $DashDuration.time_left == 0: # When the dash duration runs out
				velocity.x = SPEED * direction # Set the horizontal velocity back to normal
				playerstate = STATE_RUNNING # Reset to running state
		
		_: # If the playerstate isn't here, send an error message
			print("ERROR: playerstate \"", playerstate, "\" not found!")
