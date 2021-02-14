extends Node2D


const ESTIMATED_BULLET_TIME : float = 0.18 # estimated time for bullet to hit player in seconds for aiming purposes

var current_rotation_speed = 0


# Find the position to target
func find_target(player_pos, player_vel):
	var target_position = player_pos + Vector2(0, -8)
	target_position += ESTIMATED_BULLET_TIME * player_vel
	return atan2((target_position.y - global_position.y), (target_position.x - global_position.x))


func _physics_process(delta):
	# Aiming now works
	global_rotation = find_target(get_parent().get_node("Player").global_position, get_parent().get_node("Player").velocity)
