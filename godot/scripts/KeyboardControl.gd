extends Node
class_name KeyboardControl

@export var rocket : Rocket

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !rocket:
		return
		
	if Input.is_action_pressed("thrust"):
		rocket.thrust = 1
	else:
		rocket.thrust = 0
	
	if Input.is_action_pressed("tvc_ccw"):
		rocket.thrustAngle = 10
	elif Input.is_action_pressed("tvc_cw"):
		rocket.thrustAngle = -10
	else:
		rocket.thrustAngle = 0
