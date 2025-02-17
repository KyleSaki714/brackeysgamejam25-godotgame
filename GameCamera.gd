extends Camera3D

@export var _follow_target: Node3D
@export var _look_target: Node3D
@export_range(0,5) var _camSpeed = 0.1

func _process(delta: float) -> void:
	var newCamPos = global_position.move_toward(_follow_target.global_position, _camSpeed)
	print(newCamPos)
	global_position = newCamPos
	#look_at(_look_target.global_position)
