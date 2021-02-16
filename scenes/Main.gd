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

func _unhandled_input(event):
	if event.is_action_pressed("bullettime") && bullettime == false:
		$CanvasModulate.set_color(Color(0.8,0.8,1))
		Engine.time_scale =.3
		$BulletTimeDuration.start()


func _on_BulletTimeDuration_timeout():
	print("")
	Engine.time_scale =1
	$CanvasModulate.set_color(Color(1,1,1))
