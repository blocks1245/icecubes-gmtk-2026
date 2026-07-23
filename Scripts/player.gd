extends CharacterBody2D

## FILE PATHS

# Preload timer node paths on start of scene
@onready var dash_duration: Timer = $DashDuration
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

# Movement magnitude constants

# Running state
const SPEED: float = 300.0
const JUMP_VELOCITY: float = -600.0
const DEFAULT_GRAV: float = 1.0
# Wallcling state
const WALLJUMP_VELOCITY: float = -450.0
const WALLCLING_GRAV: float = 0.2
# Dashing state
const DASH_SPEED: float = 900.0
const DASH_GRAV: float = 0.0
# Sliding state
const SLIDE_SPEED: float = 450.0
const SLIDE_FALL_SPEED: float = 900

# Current movement direction constants
const LEFT: int = -1
const RIGHT: int = 1

## VARIABLES

var playerstate: int = STATE_START # Current physics state of the player, defaulted to start
var direction: int = RIGHT # Current direction of movement, defaulted right
var gravityMod: float = 1.0 # Current modifier on gravity, defaulted to neutral

## FUNCTIONS

# Run on start of scene
func _ready() -> void:
	await get_tree().create_timer(1).timeout # Wait one second before doing anything
	
	$dieandstartsheet.visible = true # Play the spawn animation
	$dieandstartsheet.play("Spawn") 
	
	# Wait for half of the animation to finish at 24 FPS
	await get_tree().create_timer(0.5 * $dieandstartsheet.sprite_frames.get_frame_count("Spawn") / 24).timeout
	$playersheet.visible = true # Then make the player visible
	
	await get_tree().create_timer(2.5).timeout # Wait 2.5 seconds
	$playersheet.play("default") # Play the running animation
	playerstate = STATE_RUNNING # Set the player state to running
	
# Runs every physics frame
func _physics_process(delta: float) -> void:
	StateMachine() # Determine the physics state of the player
	
	if not is_on_floor(): # If in the air
		velocity += get_gravity() * delta * gravityMod # Apply velocity from the acceleration of gravity
		# Multiplied by the number of frames in this physics frame, and the gravity modifier
	
	move_and_slide() # Move the player based on determined velocity

# Swaps the current direction of movement
func InvertMoveDirection() -> void:
	match direction:
		RIGHT:
			direction = LEFT # Set direction of movement
			$playersheet.flip_h = true # Set direction of sprite
			
		_: # Default for if currently facing left (or any unexpected case)
			direction = RIGHT
			$playersheet.flip_h = false

#Defines player states, if ur confused with how something works, start from STATE_RUNNING 
#and follow what movement should be done and you'll see how it works
func StateMachine() -> void:
	match playerstate: # Match the current player physics state to one of the following options
		STATE_START: # Neutral "do nothing" state
			pass # Do nothing (lol)
			
		STATE_RUNNING: # Moving horizontally state (the default!)
			gravityMod = DEFAULT_GRAV # Reset gravity to normal
			
			velocity.x = direction * SPEED # Set horizontal velocity
			
			if Input.is_action_just_pressed("Jump") and is_on_floor(): # If jumping
				velocity.y = JUMP_VELOCITY # Set vertical velocity
			
			if Input.is_action_just_pressed("Dash") and dash_cd.is_stopped(): # If dashing
				playerstate = STATE_DASHING # Set state to dashing
				dash_duration.start() # Start the dash timer
				
			if Input.is_action_just_pressed("Slide"): # If sliding
				playerstate = STATE_SLIDING # Enter slide state
			
			if is_on_wall(): # If touching the wall
				playerstate = STATE_WALLCLINGING # Enter wallclinging state
				if is_on_floor(): # If ALSO on the floor
					velocity.y = JUMP_VELOCITY # Set vertical velocity to jump
				
		STATE_WALLCLINGING: # Wallclinging state
			if velocity.y > 0: # If heading DOWN
				gravityMod = WALLCLING_GRAV # Reduce gravity (like mantis claw)
			else: # If heading UP
				gravityMod = DEFAULT_GRAV # Leave gravity at base
			
			if Input.is_action_just_pressed("Jump"): # If jump is pressed
				playerstate = STATE_RUNNING # Reset state to running
				velocity.y = WALLJUMP_VELOCITY # Set vertical velocity to jump
				InvertMoveDirection() # Invert movement direction (to jump AWAY from the wall)
			
			elif Input.is_action_just_pressed("Dash") and dash_cd.is_stopped(): # If dashing
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
			gravityMod = DASH_GRAV # Disable acceleration from gravity
			velocity.y = 0 # Freeze vertical velocity
			
			velocity.x = DASH_SPEED * direction # Set horizontal dash velocity
			
			if dash_duration.is_stopped(): # When the dash duration runs out
				dash_cd.start() # Start a timer for the cooldown
				if is_on_wall(): # If on a wall
					playerstate = STATE_WALLCLINGING # Reset to wallclinging state
				else: # Otherwise
					playerstate = STATE_RUNNING # Reset to running state
		
		STATE_SLIDING: # Sliding state
			if is_on_wall(): # If impacting a wall
				scale.y = 1 # Reset to normal scale
				playerstate = STATE_RUNNING # Reset to running state
				
				InvertMoveDirection() # Invert movement 
				
				dash_duration.start() # Start dash timer
				playerstate = STATE_DASHING # Enter dashing state
				
			else: # If NOT impacting a wall
				scale.y = 0.5 # Set shrunk scale (I think this is temporary until we add a real animation lol)
				if is_on_floor(): # If on the floor
					velocity.x = SLIDE_SPEED * direction # Set horizontal velocity to the sliding speed
				else: # If midair
					velocity.y += SLIDE_FALL_SPEED # Drop with increased speed (functions as a vertical dash)
				
		_: # If the playerstate isn't here, send an error message
			printerr("playerstate \"", playerstate, "\" not found!")
