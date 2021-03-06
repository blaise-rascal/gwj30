extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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
	$UILayer/HeartbeatLabel.text = "Heartbeat: " + str(int(Globals.visible_heartbeat()))

func _unhandled_input(event):
	if event.is_action_pressed("bullettime") && Globals.bullettime == false && Globals.heartbeat > 70 && Globals.gameover == false:
		$CanvasModulate.set_color(Color(0.8,0.8,1))
		Engine.time_scale = Globals.SLOW_TIME_SCALE
		$BulletTimeDuration.start()
		Globals.heartbeat = 30
		AudioServer.set_bus_effect_enabled(0, 0, true)
		Globals.bullettime = true
		$Player/ReloadTimer.wait_time = 0.25*Globals.SLOW_TIME_SCALE
		
	if(Globals.gameover == true && event.is_action_pressed("restart")):
		_restart_game()


func _on_BulletTimeDuration_timeout():
	Engine.time_scale = 1
	Globals.bullettime = false
	AudioServer.set_bus_effect_enabled(0, 0, false)
	$Player/ReloadTimer.wait_time = 0.25
	$CanvasModulate.set_color(Color(1,1,1))
	
func game_over():
	if(Globals.gameover == false):
		$LoseSound.play()
		$UILayer/HPLabel.visible = false
		Globals.gameover = true
		$UILayer/RetryLabel.visible = true
		#print("GAME OVER")

func _restart_game():
	$Player/anims.play("idle")
	$Player/gunanims.play("idle")
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


func _on_WinArea_body_entered(body):
	if(body == get_node("Player")):
		$UILayer/RetryLabel.text = "YOU MANAGED TO ESCAPE! GAME OVER"
		$UILayer/RetryLabel.visible = true
		get_tree().paused = true # Replace with function body.
