extends Area3D

class_name Trigger

enum TRIGGER_TYPES {
	DEEATH,
	ENDGAME,
	SUNSET,
	NIGHTTIME
}

@export var trigger_type: TRIGGER_TYPES
