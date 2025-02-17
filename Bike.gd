extends VehicleBody3D

@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 300 # max horsepower
@export var _torquePower = 2

#enum {
	#COASTING,
	#DRIVING
#}

func _physics_process(delta: float):
	engine_force = Input.get_axis("backward", "forward") * ENGINE_POWER
	
	var torqueConstant = Input.get_axis("tilt left", "tilt right") * _torquePower * -1
	#print(PhysicsServer3D.body_get_direct_state(get_rid()).inverse_inertia)
	apply_torque(transform.basis.z * torqueConstant)
	
