extends CharacterBody2D
# Controls the movement of the player character

## FILE PATHS

# Preload timer node paths on start of scene
@onready var dash_duration: Timer = $DashDuration
@onready var dash_cd: Timer = $DashCD
@onready var soundeffect_running: AudioStreamPlayer = $Sounds/Running
@onready var soundeffect_sliding: AudioStreamPlayer = $Sounds/Sliding
@onready var soundeffect_jump: AudioStreamPlayer = $Sounds/Jump
@onready var soundeffect_dash: AudioStreamPlayer = $Sounds/Dash

@onready var playersheet: AnimatedSprite2D = $playersheet
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

## CONSTANTS

# Player physics states
enum {
	STATE_START,
	STATE_PAUSED,
	STATE_RUNNING,
	STATE_WALLCLINGING,
	STATE_DASHING,
	STATE_SLIDING
}

# Player animation states
enum {
	ANIMATION_START,
	ANIMATION_RUNNING,
	ANIMATION_JUMPING,
	ANIMATION_FALLING,
	ANIMATION_WALLRUNNING,
	ANIMATION_WALLSLIDING,
	ANIMATION_DASHING,
	ANIMATION_SLIDING
}

# Movement magnitude constants

# Running state
const SPEED: float = 300
const JUMP_VELOCITY: float = -600
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
const BASE_SCALE: float = 1.2
const SMALL_SCALE: float = 0.6

# Current movement direction constants
const LEFT: int = -1
const RIGHT: int = 1

## VARIABLES

var currentLevel: int = LevelConfig.currentLevel # Number of the current level

# Physics state variables
var physicsEnabled: bool = false 
var playerstate: int = STATE_START # Current physics state of the player, defaulted to start
var direction: int = RIGHT # Current direction of movement, defaulted right
var gravityMod: float = 1.0 # Current modifier on gravity, defaulted to neutral
var jumpToggle: bool = false

# Animation state variable
var animationState: int 

# Variables for ability usage
var usedAbilities: Dictionary = { # Dictionary of abilities used so far in this level
	"Jump" : 0,
	"Dash" : 0,
	"Slide" : 0
}

# Dictionary from level_config.gd of abilities that can be used in this level
var availableAbilities: Dictionary = LevelConfig.LEVEL_ABILITIES[currentLevel]

var gameStarted: bool = false

## FUNCTIONS

# Run on start of scene
func _ready() -> void:
	UpdateAbilityLabels("Jump")
	UpdateAbilityLabels("Dash")
	UpdateAbilityLabels("Slide")
	
	await get_tree().create_timer(1).timeout # Wait one second before doing anything
	
	$dieandstartsheet.visible = true # Play the spawn animation
	
	# Wait for half of the animation to finish at 24 FPS
	await get_tree().create_timer(0.3 * $dieandstartsheet.sprite_frames.get_frame_count("Spawn") / 24).timeout
	playersheet.play("Idle") # Make idle animation
	playersheet.visible = true # Then make the player visible
	
	await get_tree().create_timer(2.5).timeout # Wait 2.5 seconds
	playerstate = STATE_RUNNING # Set the player state to running
	gameStarted = true
	
# Runs every physics frame
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Quit") and gameStarted:
		Signals.KillPlayer.emit()
	
	var collision
	PhysicsStateMachine() # Determine the physics state of the player
	AnimationStateMachine() # Determine the animation state of the player
	
	if not is_on_floor() and physicsEnabled and not playerstate == STATE_START: # If in the air
		velocity += get_gravity() * delta * gravityMod # Apply velocity from the acceleration of gravity
		# Multiplied by the number of frames in this physics frame, and the gravity modifier
	
	if physicsEnabled: move_and_slide() # Move the player based on determined velocity
	
	collision = get_last_slide_collision()
	if collision:
		var collider = collision.get_collider()
		#print(collider.name)
		if collider.name == "door": Signals.WinLevel.emit()
		if collider.name == "spikes": Signals.KillPlayer.emit()
		if collider.name == "bloodbag": pass
		if collider.name == "coffin": Signals.WinGame.emit()
	# move_and_slide() # Move the player based on determined velocity

func UpdateAbilityLabels(ability: String) -> void:
	var remaining: int = availableAbilities[ability] - usedAbilities[ability]
	if "Dash" in ability:
		Signals.UpdateDash.emit(remaining)
	elif "Jump" in ability:
		Signals.UpdateJump.emit(remaining)
	elif "Slide" in ability:
		Signals.UpdateSlide.emit(remaining)

# Swaps the current direction of movement
func InvertMoveDirection() -> void:
	match direction:
		RIGHT:
			direction = LEFT # Set direction of movement
			playersheet.flip_h = true # Set direction of sprite
			$CollisionShape2D.scale.x = -1.0
			
		_: # Default for if currently facing left (or any unexpected case)
			direction = RIGHT
			playersheet.flip_h = false
			$CollisionShape2D.scale.x = 1.0

# Function to request the use of an ability
func RequestAbility(ability: String) -> bool:
	if usedAbilities == availableAbilities:
			Signals.KillPlayer.emit()
			return false
	
	if usedAbilities[ability] < availableAbilities[ability]: # If there are less abilities used than the maximum
		usedAbilities[ability] += 1 # Increment the used ability upwards
		# Basic output will be removed later
		
		UpdateAbilityLabels(ability)
		
		return true # Return true (use is allowed)
	
	return false # Otherwise, return false (use is not allowed)

func _on_playersheet_animation_finished() -> void:
	if playersheet.animation == "JumpToFall":
		playersheet.play("StartFall")
	elif playersheet.animation == "StartFall":
		playersheet.play("Fall")

func play_sfx(sfx: AudioStreamPlayer = null) -> void:
	
	for s in [soundeffect_running, soundeffect_sliding, soundeffect_jump, soundeffect_dash]:
		if s.playing and not s == sfx:
			s.stop()
	if sfx:
		if sfx.playing == false:
			sfx.play()

#Defines player states, if ur confused with how something works, start from STATE_RUNNING 
#and follow what movement should be done and you'll see how it works
func PhysicsStateMachine() -> void:
	match playerstate: # Match the current player physics state to one of the following options
		STATE_START: # Neutral "do nothing" state
			velocity.x = 0
			velocity.y = 0
			
		STATE_PAUSED:
			if physicsEnabled: 
				physicsEnabled = false
				velocity.x = 0
				velocity.y = 0
			
		STATE_RUNNING: # Moving horizontally state (the default!)
			if not physicsEnabled: physicsEnabled = true
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
					collision_shape_2d.scale.y = SMALL_SCALE
					velocity.y += SLIDE_FALL_SPEED # Drop with increased speed (functions as a vertical dash)
					playerstate = STATE_SLIDING # Enter slide state
			
			if is_on_wall(): # If touching the wall
				playerstate = STATE_WALLCLINGING # Enter wallclinging state
				if is_on_floor() and not jumpToggle: # If ALSO on the floor
					velocity.y = JUMP_VELOCITY # Set vertical velocity to jump
					#jumpToggle = true
			else:
				jumpToggle = false
				
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
			
			if LevelConfig.dead:
				playerstate = STATE_START
		
		STATE_SLIDING: # Sliding state
			if is_on_wall(): # If impacting a wall
				collision_shape_2d.scale.y = BASE_SCALE # Reset to normal scale
				playerstate = STATE_RUNNING # Reset to running state
				
				InvertMoveDirection() # Invert movement 
				
				dash_duration.start() # Start dash timer
				playerstate = STATE_DASHING # Enter dashing state
				
			else: # If NOT impacting a wall
				collision_shape_2d.scale.y = SMALL_SCALE # Set shrunk scale (I think this is temporary until we add a real animation lol)
				velocity.x = SLIDE_SPEED * direction # Set horizontal velocity to the sliding speed
				
		_: # If the playerstate isn't here, send an error message
			printerr("playerstate \"", playerstate, "\" not found! (PHYSICS)")
			playerstate = STATE_RUNNING

# Tells the game what animation should be playing at any given moment
# Outputs are currently different speeds of running since I only have one animation
func AnimationStateMachine() -> void:
	match playerstate:
		STATE_START:
			if not animationState == ANIMATION_START:
				#print("Play idle animation")
				playersheet.play("Idle")
				play_sfx()
				animationState = ANIMATION_START
		
		STATE_PAUSED:
			if not animationState == ANIMATION_START:
				playersheet.play("Idle")
				play_sfx()
				animationState = ANIMATION_START
			pass
		
		STATE_RUNNING:
			if is_on_floor():
				if not animationState == ANIMATION_RUNNING:
					#print("Play running animation")
					
					playersheet.play("Running") # Play the running animation
					play_sfx(soundeffect_running)
					animationState = ANIMATION_RUNNING
			
			else:
				if velocity.y < 0:
					if not animationState == ANIMATION_JUMPING:
						#print("Play jumping animation")
						
						play_sfx(soundeffect_jump)
						playersheet.play("Jump")
						animationState = ANIMATION_JUMPING
					
				else:
					if animationState == ANIMATION_JUMPING:
						#print("Play falling transition animation")
						
						playersheet.play("JumpToFall")
						animationState = ANIMATION_FALLING
					
					elif not animationState == ANIMATION_FALLING:
						#print("Play falling start animation")
							
						playersheet.play("StartFall")
						animationState = ANIMATION_FALLING
			
		STATE_WALLCLINGING:
			if velocity.y < 0:
				if not animationState == ANIMATION_WALLRUNNING:
					#print("Play wallrun animation")
					
					play_sfx(soundeffect_sliding)
					playersheet.play("Wallclinging") # Test
					animationState = ANIMATION_WALLRUNNING
			
			else:
				if not animationState == ANIMATION_WALLSLIDING:
					#print("Play wallslide animation")
					
					play_sfx(soundeffect_sliding)
					playersheet.play("Wallsliding") # Test
					animationState = ANIMATION_WALLSLIDING
			
		STATE_DASHING:
			if not animationState == ANIMATION_DASHING:
				#print("Play dashing animation")
				
				play_sfx(soundeffect_dash)
				playersheet.play("Running", 0) # Test
				animationState = ANIMATION_DASHING
			
		STATE_SLIDING:
			if not animationState == ANIMATION_SLIDING:
				#print("Play sliding animation")
				
				playersheet.play("Sliding")
				animationState = ANIMATION_SLIDING
			
		_:
			printerr("playerstate \"", playerstate, "\" not found! (ANIMATION)")
			playerstate = STATE_RUNNING
