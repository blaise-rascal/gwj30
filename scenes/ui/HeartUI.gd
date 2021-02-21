extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var beat_timer = $BeatTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func beat_quiet():
	$anims.play("beat")
	$HeartbeatSound.volume_db = -20
	$HeartbeatSound.play()

func beat_loud():
	$anims.play("beat")
	$HeartbeatSound.volume_db = 0
	$HeartbeatSound.play()

func beat(audible):
	if audible:
		beat_loud()
	else:
		beat_quiet()




func _on_BeatTimer_timeout():
	beat(Globals.bullettime)
	beat_timer.wait_time = 60 / Globals.visible_heartbeat()
	beat_timer.start()
