extends KinematicBody2D

const BULLET = preload("res://scenes/characters/Bullet.tscn")

const MAX_SPEED : int = 260 # Pixels/second.
const LEFT_RIGHT_ACCELERATION: int = 1700 # Pixels/second2
const GROUND_DRAG_DECELERATION : int = 700 # Pixels/second2
const AIR_DRAG_DECELERATION : int = 700 # Pixels/second2
const VELOCITY_TO_STOP_DRAGGING : int = 16 # Pixels/second
const JUMP_VERTICAL_VELOCITY : int = 400 # Pixels/second
const WALL_JUMP_VERTICAL_VELOCITY : int = 300 # Pixels/second
const WALL_JUMP_HORIZONTAL_VELOCITY : int = 260 # Pixels/second
const REGULAR_GRAVITY : int = 2200 #Pixels/second2
const GRAVITY_WITH_UP_HELD : int = 1100 #Pixels/second2
#TODO: maybe increase gravity if you hold down? like celeste?

const MAX_HEALTH = 100

onready var on_ground = $OnGround
onready var on_ground_left = $OnGroundLeft
onready var on_ground_right = $OnGroundRight
onready var on_left_wall = $OnLeftWall
onready var on_right_wall = $OnRightWall
onready var coyote_time = $CoyoteTime
onready var cam_pos = $CameraPosition

var health = MAX_HEALTH
var velocity = Vector2()
var heartbeat = 0
var heartbeat_max = 100
var facing_direction = 1 # 1 is right, -1 is left

func die():
	get_tree().quit()   


func hurt(damage):
	health -= damage
	if health <= 0:
		die()


func is_on_ground():
	if on_ground.is_colliding() or on_ground_left.is_colliding() or on_ground_right.is_colliding():
		coyote_time.start()
	return coyote_time.time_left > 0


func _process(delta):
	# Increment heartbeat based on each nearby enemy
	for enemy in heartbeat_detection.get_overlapping_areas():
		heartbeat += lerp(HEARTBEAT_INC, 0, heartbeat_detection.global_position.distance_to(enemy.global_position) / HEARTBEAT_RADIUS) * delta
	
	# Decrement heartbeat when no enemies are around
	if heartbeat_detection.get_overlapping_areas().size() == 0:
		heartbeat -= HEARTBEAT_DECREASE_AMOUNT * delta
	
	heartbeat = clamp(heartbeat, 0, heartbeat_max)
	
	# TEMPORARY
	$HeartbeatLabel.text = str(heartbeat)


func _physics_process(delta):
	var acceleration = Vector2(0,0)  # The player's movement vector.
	
	#ACCELERATION IS CALCULATED EVERY FRAME FROM SCRATCH
	#VELOCITY IS PRESERVED FROM FRAME TO FRAME, BUT MODIFIED BY ACCELERATION (AND SOMETIMES SET EXPLICITY, LIKE WHEN YOU JUMP)
	
	if Input.is_action_pressed("right"): #TODO: Make it so that it only adds walk acceleration if the velocity is not too high already (rather than handling this case later on)
		acceleration.x = LEFT_RIGHT_ACCELERATION
		facing_direction = 1
	if Input.is_action_pressed("left"):
		acceleration.x = -LEFT_RIGHT_ACCELERATION
		facing_direction = -1
	if Input.is_action_just_pressed("jump"):
		if is_on_ground():
			velocity.y = -JUMP_VERTICAL_VELOCITY
		elif on_left_wall.is_colliding():
			velocity.y = -WALL_JUMP_VERTICAL_VELOCITY
			velocity.x = WALL_JUMP_HORIZONTAL_VELOCITY
		elif on_right_wall.is_colliding():
			velocity.y = -WALL_JUMP_VERTICAL_VELOCITY
			velocity.x = -WALL_JUMP_HORIZONTAL_VELOCITY

	
	# Apply gravity
	if(Input.is_action_pressed("jump") && velocity.y<0): #If you're jumping and the up button is held, make gravity lower
		#print("UP HELD")
		acceleration.y = GRAVITY_WITH_UP_HELD
	else:
		#print("REGULAR GRAVITY")
		acceleration.y = REGULAR_GRAVITY
	
	#Apply drag
	if acceleration.x == 0:
		#$CharAnims.play("idle")
		#VELOCITY_TO_STOP_DRAGGING is the (very slow) speed where, if the player is moving below that speed, their velocity is set to zero.
		#Used to prevent rapid switching of directions when they coast to a halt.
		if(abs(velocity.x) > VELOCITY_TO_STOP_DRAGGING) :
			if is_on_ground():
				acceleration.x = -GROUND_DRAG_DECELERATION * clamp(velocity.x, -1, 1)
			else:
				acceleration.x = -AIR_DRAG_DECELERATION * clamp(velocity.x, -1, 1)
		else:
			velocity.x = 0
#	else:
#		if(acceleration.x >0):
#			$Sprite.flip_h=true
#		elif(acceleration.x <0):
#			$Sprite.flip_h=false
#		$CharAnims.play("walk")
	
	# Apply acceleration
	if acceleration.length() > 0:
		velocity += acceleration * delta
		#Clamp velocity to max
		if(abs(velocity.x) > MAX_SPEED):
			velocity.x = clamp(velocity.x, -1, 1) * MAX_SPEED
	
	# Move camera ahead of player
	cam_pos.position = lerp(cam_pos.position, velocity * delta * 3, 0.1)
	
	velocity = move_and_slide(velocity, Vector2(0, -1))


func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		var bullet = BULLET.instance()
		bullet.global_position = global_position + Vector2(0, -8)
		bullet.global_rotation = Vector2(facing_direction + clamp(velocity.x, -1, 1), int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))).angle()
		bullet.target_enemy()
		get_tree().get_root().add_child(bullet)

func _on_Hurtbox_area_entered(bullet):
	hurt(bullet.DAMAGE)
	bullet.queue_free()
