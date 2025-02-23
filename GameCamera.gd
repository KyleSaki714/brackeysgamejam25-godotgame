extends Camera3D

@export var _bike: VehicleBody3D
@export var _follow_target: Node3D
@export var _look_target: Node3D
@export_range(0,5) var _camSpeed = 0.1
const distMult = 500.0

func _process(delta: float) -> void:
	if not _bike._lockBike:
		var newCamPos = global_position.move_toward(_follow_target.global_position, _camSpeed)
		#print(newCamPos)
		global_position = newCamPos
	
	var distToBike = global_position.distance_to(_follow_target.global_position)
	if distToBike > 50:
		_camSpeed += distToBike / distMult
		print(_camSpeed)
	
	#look_at(_look_target.global_position)
	if Input.is_action_pressed("DEBUG_cam_zoom_in"):
		fov -= 0.1
	if Input.is_action_pressed("DEBUG_cam_zoom_out"):
		fov += 0.1
	
