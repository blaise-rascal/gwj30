extends KinematicBody2D

const MAX_SPEED : int = 260 # Pixels/second.
const ACCELERATION_MODIFIER : int = 1200 # Pixels/second
const DRAG_COEF: float = -0.9 # Ratio
const VELOCITY_TO_STOP_DRAGGING : int = 16 # Pixels/second

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

	acceleration = acceleration.normalized()
	
	#See if the character needs to drag to a halt
	if acceleration.length() == 0:
		#$CharAnims.play("idle")
		if(velocity.length()>VELOCITY_TO_STOP_DRAGGING) :
			acceleration = DRAG_COEF * velocity.normalized()
		else:
			velocity.x = 0
			velocity.y = 0
#	else:
#		if(acceleration.x >0):
#			$Sprite.flip_h=true
#		elif(acceleration.x <0):
#			$Sprite.flip_h=false
#		$CharAnims.play("walk")
	
	
	# Apply acceleration modifier & do other stuff
	if acceleration.length() > 0:
		acceleration = acceleration * ACCELERATION_MODIFIER
		velocity += acceleration * delta
		if(velocity.length() > MAX_SPEED):
			velocity = velocity.normalized() * MAX_SPEED
			
	velocity = move_and_slide(velocity)
