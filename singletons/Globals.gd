extends Node


# Declare member variables here. Examples:
var SLOW_TIME_SCALE : float = 0.25 # When heartbeat mode is activated, the world moves at 1/4 speed
var PLAYER_TIME_SCALE : float = 2  # But the player is adjusted to move at 2x speed, so they move at 0.5x speed overall
var ADJUSTMENT_TO_CENTER_OF_PLAYER = Vector2(0,-8)
var gameover = false
var bullettime = false
#In
# var b = "text"

var heartbeat = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func visible_heartbeat():
	return 80 + 0.9 * heartbeat

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
