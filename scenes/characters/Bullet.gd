extends Area2D

const HEARTBEAT_GIVER = preload("res://scenes/characters/HeartbeatGiver.tscn")

export (Vector2) var VELOCITY = Vector2(350, 0)
export (int) var DAMAGE = 5

func _physics_process(delta):
	global_position += (VELOCITY * delta).rotated(global_rotation)

func target_enemy():
	set_collision_layer_bit(3, true)

func target_player():
	set_collision_layer_bit(2, true)


func _on_Bullet_body_entered(body):
	queue_free()
