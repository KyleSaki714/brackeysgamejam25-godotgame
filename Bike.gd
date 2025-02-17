extends VehicleBody3D

@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 300 # max horsepower

func _physics_process(delta: float):
	engine_force = Input.get_axis("backward", "forward") * ENGINE_POWER
