extends KinematicBody2D

const BULLET = preload("res://scenes/characters/BlaiseBullet.tscn")

const MAX_SPEED : int = 240 # Pixels/second.
const LEFT_RIGHT_ACCELERATION: int = 1600 # Pixels/second2
const GROUND_DRAG_DECELERATION : int = 700 # Pixels/second2
const AIR_DRAG_DECELERATION : int = 700 # Pixels/second2
const VELOCITY_TO_STOP_DRAGGING : int = 16 # Pixels/second
const JUMP_VERTICAL_VELOCITY : int = 380 # Pixels/second
const WALL_JUMP_VERTICAL_VELOCITY : int = 250 # Pixels/second
const WALL_JUMP_HORIZONTAL_VELOCITY : int = 260 # Pixels/second
const REGULAR_GRAVITY : int = 2000 #Pixels/second2
const GRAVITY_WITH_UP_HELD : int = 1000 #Pixels/second2
const DEFAULT_CAMERA_POSITION = Vector2(0,-50)
const HEARTBEAT_INC : int = 100 # Heartbeat/second
const HEARTBEAT_RADIUS : int = 120 # Maximum distance from enemy where heartbeat is generated
const HEARTBEAT_DECREASE_AMOUNT : int = 3 # Decrease in heartbeat per second when not near enemies
const DASH_SPEED : int = 400 # Pixels / second
#TODO: maybe increase gravity if you hold down? like celeste?

const MAX_HEALTH = 100

onready var on_ground = $OnGround
onready var on_ground_left = $OnGroundLeft
onready var on_ground_right = $OnGroundRight
onready var on_left_wall = $OnLeftWall
onready var on_right_wall = $OnRightWall
onready var coyote_time = $CoyoteTime
onready var cam_pos = $CameraPosition
onready var heartbeat_detection = $HeartbeatDetector
onready var dash_timer = $DashTimer

var health = MAX_HEALTH
var velocity = Vector2()
var facing_direction = 1 # 1 is right, -1 is left
var dashing = false
var dash_direction = Vector2()
var bulletready = true
var is_walking = false


func die():
	get_tree().get_root().get_node("Main").game_over()


func hurt(damage):
	$hurtsound.play()
	health -= damage
	if health <= 0:
		$anims.play("die")
		die()


func is_on_ground():
	if on_ground.is_colliding() or on_ground_left.is_colliding() or on_ground_right.is_colliding():
		coyote_time.start()
	return coyote_time.time_left > 0

func _process(delta):
	if(Input.is_action_pressed("pancamera")):
		var PanAlongVector = get_local_mouse_position() - Globals.ADJUSTMENT_TO_CENTER_OF_PLAYER + DEFAULT_CAMERA_POSITION
		#$CameraPosition.position = Vector2(PanAlongVector.length()*.5,0).rotated(_get_angle_from_sprite_center_to_mouse())
		$CameraPosition.position = PanAlongVector*.5
	else:
		$CameraPosition.position = DEFAULT_CAMERA_POSITION + Vector2(velocity.x, 0) / 5
	
	
	# Increment heartbeat based on each nearby enemy
	for enemy in heartbeat_detection.get_overlapping_areas():
		Globals.heartbeat += lerp(HEARTBEAT_INC, 0, heartbeat_detection.global_position.distance_to(enemy.global_position) / HEARTBEAT_RADIUS) * delta
	
	# Decrement heartbeat when no enemies are around
	if heartbeat_detection.get_overlapping_areas().size() == 0:
		Globals.heartbeat -= HEARTBEAT_DECREASE_AMOUNT * delta
	
	Globals.heartbeat = clamp(Globals.heartbeat, 0, 100)



func _get_angle_from_sprite_center_to_mouse():
	return atan2(get_local_mouse_position().y - Globals.ADJUSTMENT_TO_CENTER_OF_PLAYER.y, get_local_mouse_position().x - Globals.ADJUSTMENT_TO_CENTER_OF_PLAYER.x)

func _physics_process(delta):
	if dashing:
		velocity = dash_direction * DASH_SPEED
	else:
		var acceleration = Vector2(0,0)  # The player's movement vector.
		
		#ACCELERATION IS CALCULATED EVERY FRAME FROM SCRATCH
		#VELOCITY IS PRESERVED FROM FRAME TO FRAME, BUT MODIFIED BY ACCELERATION (AND SOMETIMES SET EXPLICITY, LIKE WHEN YOU JUMP)
		if(Globals.gameover == false):
			if Input.is_action_pressed("right"):
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

		if(acceleration.x == 0):
			is_walking = false
		else:
			is_walking = true
				
		# Apply gravity
		if(Input.is_action_pressed("jump") && velocity.y<0 && Globals.gameover == false): #If you're jumping and the up button is held, make gravity lower
			acceleration.y = GRAVITY_WITH_UP_HELD
		else:
			acceleration.y = REGULAR_GRAVITY
		
		#Apply drag
		if acceleration.x == 0:
			#VELOCITY_TO_STOP_DRAGGING is the (very slow) speed where, if the player is moving below that speed, their velocity is set to zero.
			#Used to prevent rapid switching of directions when they coast to a halt.
			if(abs(velocity.x) > VELOCITY_TO_STOP_DRAGGING) :
				if is_on_ground():
					acceleration.x = -GROUND_DRAG_DECELERATION * clamp(velocity.x, -1, 1)
				else:
					acceleration.x = -AIR_DRAG_DECELERATION * clamp(velocity.x, -1, 1)
			else:
				velocity.x = 0
		else:
			if(acceleration.x >0):
				$PlayerSprite.flip_h=false
				$ShootSprite.flip_h=false
			elif(acceleration.x <0):
				$PlayerSprite.flip_h=true
				$ShootSprite.flip_h=true
		
		# Apply acceleration
		if acceleration.length() > 0:
			velocity += acceleration * delta
			#Clamp velocity to max
			if(abs(velocity.x) > MAX_SPEED):
				velocity.x = clamp(velocity.x, -1, 1) * MAX_SPEED

		if(Globals.gameover == true):
			$anims.play("die")
		else:
			if(is_walking && is_on_ground()):
				$anims.play("walk")
			else:
				$anims.play("idle")
	
	velocity = move_and_slide(velocity, Vector2(0, -1))


func _unhandled_input(event):
	if(Globals.gameover == false):
		if event.is_action_pressed("shoot"):
			if bulletready:
				$gunanims.play("shoot")
				bulletready = false
				$ReloadTimer.start()
				var bullet = BULLET.instance()
				var adjustedglobalposition = global_position + Globals.ADJUSTMENT_TO_CENTER_OF_PLAYER
				#var adjustedlocalposition = position + Globals.ADJUSTMENT_TO_CENTER_OF_PLAYER
				bullet.global_position = adjustedglobalposition
				
				bullet.global_rotation = _get_angle_from_sprite_center_to_mouse()
				print(get_local_mouse_position())
				bullet.target_enemy()
				get_tree().get_root().add_child(bullet)
		
		if event.is_action_pressed("dash") and Globals.heartbeat > 10:
			dashing = true
			dash_direction = Vector2(int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")), 
									int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))).normalized()
			dash_timer.start()
			Globals.heartbeat -= 10

func _on_Hurtbox_area_entered(bullet):
	hurt(bullet.DAMAGE)
	bullet.queue_free()



func _on_DashTimer_timeout():
	dashing = false


func _on_ReloadTimer_timeout():
	bulletready = true
