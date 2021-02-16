extends Node


# Declare member variables here. Examples:
var SLOW_TIME_SCALE : float = 0.25 # When heartbeat mode is activated, the world moves at 1/4 speed
var PLAYER_TIME_SCALE : float = 2  # But the player is adjusted to move at 2x speed, so they move at 0.5x speed overall
var ADJUSTMENT_TO_CENTER_OF_PLAYER = Vector2(0,-8)
#In
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
