extends KinematicBody2D

const MAX_SPEED : int = 260 # Pixels/second.
const ACCELERATION_MODIFIER : int = 1200 # Pixels/second
const DRAG_COEF: float = -0.9 # Ratio
const VELOCITY_TO_STOP_DRAGGING : int = 16 # Pixels/second
const JUMP_ACCELERATION : int = 20 # Some unit, not really sure what tbh
const GRAVITY : int = 1 # See above comment

onready var onGround = $OnGround

var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _physics_process(delta):
	var acceleration = Vector2(0,0)  # The player's movement vector.
	if Input.is_action_pressed("ui_right"):
		acceleration.x += 1
	if Input.is_action_pressed("ui_left"):
		acceleration.x -= 1
	if Input.is_action_just_pressed("ui_up") && onGround.is_colliding():
		acceleration.y -= JUMP_ACCELERATION

	acceleration.x = clamp(acceleration.x, -1, 1)
	
	# Apply gravity
	if !onGround.is_colliding():
		acceleration.y += GRAVITY
	
	#See if the character needs to drag to a halt
	if acceleration.x == 0:
		#$CharAnims.play("idle")
		if(abs(velocity.x) > VELOCITY_TO_STOP_DRAGGING) :
			acceleration.x = DRAG_COEF * clamp(velocity.x, -1, 1)
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
		if(velocity.x > MAX_SPEED):
			velocity.x = clamp(velocity.x, -1, 1) * MAX_SPEED
	velocity = move_and_slide(velocity, Vector2(0, 1))
