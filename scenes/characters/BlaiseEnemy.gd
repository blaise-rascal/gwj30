extends Node2D

const BULLET = preload("res://scenes/characters/BlaiseBullet.tscn")

const ESTIMATED_BULLET_TIME : float = 0.18 # estimated time for bullet to hit player in seconds for aiming purposes

const MAX_HEALTH = 20
var health = MAX_HEALTH
var alive = true
var player_in_sight = true

#The export vars are used to differentiate the different enemies
export var baserotation = 0

func _ready():
	for child in get_children():
		if(child.is_in_group("BaseRotates")):
			child.position = child.position.rotated(rotation_degrees*PI/180)
			child.rotation_degrees = baserotation



func die():
	$ExplodeSound.play()
	alive = false
	$ShootTimer.stop()
	$anims.play("die")


func hurt(damage):
	print("ow")
	health -= damage
	if health <= 0:
		die()


# Find the position to target
func find_target(player_pos):
	var target_position = player_pos + Globals.ADJUSTMENT_TO_CENTER_OF_PLAYER
	return atan2((target_position.y - global_position.y), (target_position.x - global_position.x))


func _physics_process(delta):
	# Aiming now works
	#$RotatingPart.rotate(find_target(get_parent().get_parent().get_node("Player").global_position, get_parent().get_parent().get_node("Player").velocity))
	
	if(alive):
		$PlayerDetector.position = Vector2($PlayerDetector.position.length(),0).rotated(find_target(get_parent().get_parent().get_node("Player").global_position))
		$PlayerDetector.global_rotation = find_target(get_parent().get_parent().get_node("Player").global_position)
		
		if($PlayerDetector.get_collider() == get_parent().get_parent().get_node("Player/Hurtbox")):
			if(player_in_sight == false):
				#The player just came into view!
				$ShootTimer.start()
				player_in_sight = true
				$anims.play("hostile")
			#The player has been in view for a while!
			$BulletSpawn.position = Vector2($BulletSpawn.position.length(),0).rotated(find_target(get_parent().get_parent().get_node("Player").global_position))
			$Barrel.global_rotation = find_target(get_parent().get_parent().get_node("Player").global_position)
		else:
			if(player_in_sight == true):
				#The player just went out of view!
				$anims.play("idle")
				$Barrel.global_rotation = baserotation*PI/180
				player_in_sight = false
				$ShootTimer.stop()
			
		

func _on_ShootTimer_timeout():
	$anims.play("shoot")

func shootbullet():
	var bullet = BULLET.instance()
	print($BulletSpawn.global_position)
	bullet.global_position = $BulletSpawn.global_position
	bullet.global_rotation = find_target(get_parent().get_parent().get_node("Player").global_position)
	bullet.target_player()
	get_tree().get_root().add_child(bullet)
	


func _on_Hurtbox_area_entered(bullet):
	if(alive):
		hurt(bullet.DAMAGE)
	bullet.queue_free()


func respawn():
	health = MAX_HEALTH
	alive = true
	$anims.play("idle")
	
