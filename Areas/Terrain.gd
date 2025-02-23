extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var curve = $Path2D.curve
	#var polygon = curve.get_baked_points()
	
	var curvePoints3d = $Path3D.curve.get_baked_points()
	print($Path3D.curve.get_baked_points())
	$CollisionPolygon3D.polygon = convertPackedV3ArrayIntoPackedV2Array(curvePoints3d)
	#print(type_string(typeof($Path3D.curve.get_baked_points())))
	print($CollisionPolygon3D.polygon)
	print("created polygon")


func convertPackedV3ArrayIntoPackedV2Array(v3arr: PackedVector3Array) -> PackedVector2Array:
	var res: PackedVector2Array = PackedVector2Array()
	for vec3 in v3arr:
		res.append(Vector2(vec3.x, vec3.y))
	return res
	
