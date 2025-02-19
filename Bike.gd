extends VehicleBody3D

@onready var _graphics = $Graphics
@onready var _wheel1 = $VehicleWheel3D
@onready var _wheel2 = $VehicleWheel3D2

@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 125 # max horsepower
const ENGINE_ACCEL = 40
@export var MAX_SPEED = 32.0
@export var _torquePower = 175 # "tilt" power
@export var COMSHIFT = 1 # how far from the center the center of mass shifts while tilting
@export var COMSHIFTACCEL = 0.1 # how fast the center of mass shifts when tilting
@export var JUMPFORCE = 50


var _currentCenterOfMassShift: float = 0
var _speedVal = 0.0;
var _isGrounded = false

#enum {
	#COASTING,
	#DRIVING
#}

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# - SPEED CAP -
	#linear_velocity.clampf(0, 35.0)
	#linear_velocity = linear_velocity.clampf(-30.0, 30.0)
	state.set_linear_velocity(get_linear_velocity().clampf(-MAX_SPEED, MAX_SPEED))
	#print(get_linear_velocity().length())
	
	# 
	_speedVal = state.get_linear_velocity().length() / MAX_SPEED
	#print(_speedVal)
	
	# - JUMP -
	# it's a little hop to get over ~5m. 
	var jumpBtn = Input.is_action_just_pressed("jump")
	if (_isGrounded && jumpBtn):
		var jumpVec = transform.basis.y * (JUMPFORCE * _speedVal)
		state.apply_impulse(jumpVec)
		print(jumpVec)

func _physics_process(delta: float):
	# - is Grounded -
	_isGrounded = _wheel1.is_in_contact() || _wheel2.is_in_contact()
	print(_isGrounded)
	
	# - GAS -
	var cycling = Input.get_axis("backward", "forward")
	checkCycleAnim(cycling)
	if cycling:
		engine_force += cycling * ENGINE_ACCEL
		engine_force = clampf(engine_force, ENGINE_POWER * -1, ENGINE_POWER)
	else:
		# coasting
		engine_force = 0
	#print(engine_force)
	
	# - TILT -
	# apply torque
	var tiltAxis = Input.get_axis("tilt left", "tilt right")
	checkTiltAnim(tiltAxis)
	if (tiltAxis != 0):
		var torqueConstant = tiltAxis * _torquePower * -1
		#print(PhysicsServer3D.body_get_direct_state(get_rid()).inverse_inertia)
		apply_torque(transform.basis.z * torqueConstant)
		
		# shift center of mass
		# reference: freerider game, the guy kinda tilts back or forward to shift the CoM
		center_of_mass_mode = CENTER_OF_MASS_MODE_CUSTOM
		_currentCenterOfMassShift += tiltAxis * COMSHIFTACCEL
		_currentCenterOfMassShift = clampf(_currentCenterOfMassShift, COMSHIFT * -1, COMSHIFT)
		center_of_mass = Vector3(_currentCenterOfMassShift, 0.0, 0.0)
		#print(_currentCenterOfMassShift)
		
	else:
		center_of_mass = Vector3.ZERO
		_currentCenterOfMassShift = 0
		center_of_mass_mode = CENTER_OF_MASS_MODE_AUTO

	

func checkCycleAnim(axisValue):
	if (axisValue > 0):
		$Graphics/Legs.play("Pedaling")
	elif (axisValue < 0):
		$Graphics/Legs.play_backwards("Pedaling")
	else:
		$Graphics/Legs.stop()

func checkTiltAnim(axisValue):
	if (axisValue > 0):
		$Graphics/Coast.hide()
		$Graphics/LeanBack.hide()
		$Graphics/LeanForward.show()
	elif (axisValue < 0):
		$Graphics/Coast.hide()
		$Graphics/LeanBack.show()
		$Graphics/LeanForward.hide()
	else:
		$Graphics/Coast.show()
		$Graphics/LeanBack.hide()
		$Graphics/LeanForward.hide()
