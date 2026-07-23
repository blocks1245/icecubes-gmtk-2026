extends CharacterBody2D
# Controls the movement of the player character

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

var currentLevel: int = LevelConfig.currentLevel # Number of the current level

# Physics state variables
var playerstate: int = STATE_START # Current physics state of the player, defaulted to start
var direction: int = RIGHT # Current direction of movement, defaulted right
var gravityMod: float = 1.0 # Current modifier on gravity, defaulted to neutral

# Variables for ability usage
var usedAbilities: Dictionary = { # Dictionary of abilities used so far in this level
	"Jump" : 0,
	"Dash" : 0,
	"Slide" : 0
}

# Dictionary from level_config.gd of abilities that can be used in this level
var availableAbilities: Dictionary = LevelConfig.LEVEL_ABILITIES[currentLevel]

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

# Function to request the use of an ability
func RequestAbility(ability) -> bool:
	if usedAbilities[ability] < availableAbilities[ability]: # If there are less abilities used than the maximum
		usedAbilities[ability] += 1 # Increment the used ability upwards
		# Basic output will be removed later
		print("Used ", ability, ": ", usedAbilities[ability],"/",availableAbilities[ability])
		
		return true # Return true (use is allowed)
		
	print("Cannot use ", ability, ": ", usedAbilities[ability],"/",availableAbilities[ability])
	
	return false # Otherwise, return false (use is not allowed)

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
				if RequestAbility("Jump"): # If there is a jump ability remaining
					velocity.y = JUMP_VELOCITY # Set vertical velocity
			
			if Input.is_action_just_pressed("Dash") and dash_cd.is_stopped(): # If dashing
				if RequestAbility("Dash"): # If there is a dash ability remaining
					playerstate = STATE_DASHING # Set state to dashing
					dash_duration.start() # Start the dash timer
				
			if Input.is_action_just_pressed("Slide"): # If sliding
				if RequestAbility("Slide"): # If there is a slide ability remaining
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
				if RequestAbility("Jump"): # If there is a jump ability remaining
					playerstate = STATE_RUNNING # Reset state to running
					velocity.y = WALLJUMP_VELOCITY # Set vertical velocity to jump
					InvertMoveDirection() # Invert movement direction (to jump AWAY from the wall)
			
			elif Input.is_action_just_pressed("Dash") and dash_cd.is_stopped(): # If dashing
				if RequestAbility("Dash"): # If there is a dash ability remaining
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
