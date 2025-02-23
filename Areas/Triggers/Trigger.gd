extends Area3D

class_name Trigger

enum TRIGGER_TYPES {
	ENDHOME,
	SUNSET,
	NIGHTTIME
}

@export var power_type: TRIGGER_TYPES
