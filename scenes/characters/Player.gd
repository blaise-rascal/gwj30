extends KinematicBody2D

const MAX_SPEED : int = 260 # Pixels/second.
const ACCELERATION_MODIFIER : int = 1500 # Pixels/second
const DRAG_COEF : float = -0.999 # Ratio
const AIR_DRAG : float = -0.3 # Ratio
const VELOCITY_TO_STOP_DRAGGING : int = 16 # Pixels/second
const JUMP_ACCELERATION : int = 17 # Some unit, not really sure what tbh
const WALL_JUMP_ACCELERATION : int = 12 # see above comment
const GRAVITY : int = 1 # See above comment

onready var on_ground = $OnGround
onready var on_ground_left = $OnGroundLeft
onready var on_ground_right = $OnGroundRight
onready var on_left_wall = $OnLeftWall
onready var on_right_wall = $OnRightWall
onready var coyote_time = $CoyoteTime

var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func is_on_ground():
	if on_ground.is_colliding() or on_ground_left.is_colliding() or on_ground_right.is_colliding():
		coyote_time.start()
	return coyote_time.time_left > 0


func _physics_process(delta):
	var acceleration = Vector2(0,0)  # The player's movement vector.
	if Input.is_action_pressed("ui_right"):
		acceleration.x += 1
	if Input.is_action_pressed("ui_left"):
		acceleration.x -= 1
	if Input.is_action_just_pressed("ui_up"):
		if is_on_ground():
			velocity.y = 0
			acceleration.y -= JUMP_ACCELERATION
		elif on_left_wall.is_colliding():
			velocity.y = 0
			acceleration.y -= WALL_JUMP_ACCELERATION
			velocity.x = MAX_SPEED
		elif on_right_wall.is_colliding():
			velocity.y = 0
			acceleration.y -= WALL_JUMP_ACCELERATION
			velocity.x = -MAX_SPEED

	acceleration.x = clamp(acceleration.x, -1, 1)
	
	# Apply gravity
	acceleration.y += GRAVITY
	
	#See if the character needs to drag to a halt
	if acceleration.x == 0:
		#$CharAnims.play("idle")
		if(abs(velocity.x) > VELOCITY_TO_STOP_DRAGGING) :
			if is_on_ground():
				acceleration.x = DRAG_COEF * clamp(velocity.x, -1, 1)
			else:
				acceleration.x = AIR_DRAG * clamp(velocity.x, -1, 1)
		else:
			velocity.x = 0
#	else:
#		if(acceleration.x >0):
#			$Sprite.flip_h=true
#		elif(acceleration.x <0):
#			$Sprite.flip_h=false
#		$CharAnims.play("walk")
	
	# Apply acceleration modifier & do other stuff
	if acceleration.length() > 0:
		acceleration *= ACCELERATION_MODIFIER
		velocity += acceleration * delta
		if(abs(velocity.x) > MAX_SPEED):
			velocity.x = clamp(velocity.x, -1, 1) * MAX_SPEED
	velocity = move_and_slide(velocity, Vector2(0, -1))
