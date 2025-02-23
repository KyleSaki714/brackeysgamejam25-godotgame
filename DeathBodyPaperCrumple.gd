extends RigidBody3D

@onready var papercrumple1: Material = preload("res://assets/Textures/PaperCrumple1.tres")
@onready var papercrumple2: Material = preload("res://assets/Textures/PaperCrumple2.tres")
@onready var papercrumple3: Material = preload("res://assets/Textures/PaperCrumple3.tres")

var rand = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var randint = rand.randi_range(1, 3)
	match randint:
		1:
			$MeshInstance3D.set_surface_override_material(0, papercrumple1)
		2:
			$MeshInstance3D.set_surface_override_material(0, papercrumple2)
		3:
			$MeshInstance3D.set_surface_override_material(0, papercrumple3)
	
	randint = rand.randi_range(1, 3)
	match randint:
		1:
			$AudioStreamPlayer3D.play()
		2:
			$AudioStreamPlayer3D2.play()
		3:
			$AudioStreamPlayer3D3.play()
