extends RigidBody2D
class_name Rocket

@export var thrust : float = 0.0
@export var thrustAngle : float = 0.0

@export var power : float = 100.0
@export var maxThrustAngle : float = 10

var heading : float = 0.0
var velocity = Vector2.ZERO
@export var actThrust : Vector2 = Vector2.ZERO
@export var posThrust : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setControl(newThrust: float, newThrustAngle: float):
	thrust = newThrust
	thrustAngle = newThrustAngle
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Exhaust.rotation_degrees = thrustAngle
	
	if thrust > 0:
		$Exhaust.emitting = true
	else:
		$Exhaust.emitting = false

func _physics_process(delta):
	var actThrustAngle : float = thrustAngle
	
	if actThrustAngle > maxThrustAngle:
		actThrustAngle = maxThrustAngle
	elif actThrustAngle < -maxThrustAngle:
		actThrustAngle = -maxThrustAngle
	
	actThrust = Vector2(0.0, -1.0).rotated($Exhaust.global_rotation) * thrust * power
	posThrust = $Exhaust.global_position - global_position
	#var localThrust = actThrust.rotated($Exhaust.global_rotation)
	apply_force(actThrust, posThrust)
