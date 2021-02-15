extends Node2D

const BULLET = preload("res://scenes/characters/Bullet.tscn")

const ESTIMATED_BULLET_TIME : float = 0.18 # estimated time for bullet to hit player in seconds for aiming purposes

const MAX_HEALTH = 30

var health = MAX_HEALTH
var current_rotation_speed = 0


func die():
	queue_free()


func hurt(damage):
	print("ow")
	health -= damage
	if health <= 0:
		die()


# Find the position to target
func find_target(player_pos, player_vel):
	var target_position = player_pos + Vector2(0, -8)
	target_position += ESTIMATED_BULLET_TIME * player_vel
	return atan2((target_position.y - global_position.y), (target_position.x - global_position.x))


func _physics_process(delta):
	# Aiming now works
	global_rotation = find_target(get_parent().get_node("NewPlayer").global_position, get_parent().get_node("NewPlayer").velocity)


func _on_ShootTimer_timeout():
	var bullet = BULLET.instance()
	bullet.global_position = global_position
	bullet.global_rotation = global_rotation
	bullet.target_player()
	get_tree().get_root().add_child(bullet)


func _on_Hurtbox_area_entered(bullet):
	hurt(bullet.DAMAGE)
	bullet.queue_free()
