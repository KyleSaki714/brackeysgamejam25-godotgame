extends VehicleBody3D

@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 300 # max horsepower
@export var _torquePower = 150 # "tilt" power
@export var COMSHIFT = 1 # how far from the center the center of mass shifts while tilting
@export var COMSHIFTACCEL = 0.1 # how fast the center of mass shifts when tilting

var _currentCenterOfMassShift: float = 0

#enum {
	#COASTING,
	#DRIVING
#}

func _physics_process(delta: float):
	engine_force = Input.get_axis("backward", "forward") * ENGINE_POWER
	
	# - TILT -
	# apply torque
	var tiltAxis = Input.get_axis("tilt left", "tilt right")
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
		print(_currentCenterOfMassShift)
		
	else:
		center_of_mass = Vector3.ZERO
		_currentCenterOfMassShift = 0
		center_of_mass_mode = CENTER_OF_MASS_MODE_AUTO
		
	
	
	
	
