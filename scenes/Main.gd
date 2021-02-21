extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var bullettime = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#Engine.time_scale =.5
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	_update_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#TODO: Maybe make it so the ui is not updated every time _process() occurs to be more efficient
	_update_ui()
#
func _update_ui():
	$UILayer/HPLabel.text = "HP: " + str($Player.health)
#	$UILayer/BulletsLabel.text = "Bullets: " + str($Player.)
	$UILayer/HeartbeatLabel.text = "Heartbeat: " + str(Globals.heartbeat)

func _unhandled_input(event):
	if event.is_action_pressed("bullettime") && bullettime == false && Globals.heartbeat > 70 && Globals.gameover == false:
		$CanvasModulate.set_color(Color(0.8,0.8,1))
		Engine.time_scale = Globals.SLOW_TIME_SCALE
		$BulletTimeDuration.start()
		Globals.heartbeat = 30
		
	if(Globals.gameover == true && event.is_action_pressed("restart")):
		_restart_game()


func _on_BulletTimeDuration_timeout():
	Engine.time_scale = 1
	$CanvasModulate.set_color(Color(1,1,1))
	
func game_over():
	$UILayer/HPLabel.visible = false
	Globals.gameover = true
	$UILayer/RetryLabel.visible = true
	#print("GAME OVER")

func _restart_game():
	
	$Player.health = $Player.MAX_HEALTH
	$Player.position = $PlayerSpawn.position
	Globals.gameover = false
	$UILayer/RetryLabel.visible = false
	$UILayer/HPLabel.visible = true
	Globals.heartbeat = 0
	_on_BulletTimeDuration_timeout()
	get_tree().call_group("Enemies", "respawn")
	get_tree().call_group("Bullets", "queue_free")
	#reset heartbeat, reset health of player and enemies, despawn bullets, set location of player, set enemies to alive
