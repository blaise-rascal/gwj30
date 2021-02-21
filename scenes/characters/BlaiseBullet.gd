extends Area2D

# NEW
const HEARTBEAT_GIVER = preload("res://scenes/characters/HeartbeatGiver.tscn")

export (Vector2) var VELOCITY = Vector2(500, 0)
export (int) var DAMAGE = 20


func _physics_process(delta):
	global_position += (VELOCITY * delta).rotated(global_rotation)

func target_enemy():
	set_collision_layer_bit(3, true)

func target_player():
	set_collision_layer_bit(2, true)
	# NEW
	add_child(HEARTBEAT_GIVER.instance())

func _on_Bullet_body_entered(body):
	print(body)
	queue_free()
