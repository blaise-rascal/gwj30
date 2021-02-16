extends Area2D



export (Vector2) var VELOCITY = Vector2(1200, 0)
export (int) var DAMAGE = 5

func _physics_process(delta):
	global_position += (VELOCITY * delta).rotated(global_rotation)

func target_enemy():
	set_collision_layer_bit(3, true)

func target_player():
	set_collision_layer_bit(2, true)


func _on_Bullet_body_entered(body):
	queue_free()
