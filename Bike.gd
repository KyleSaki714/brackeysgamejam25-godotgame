extends VehicleBody3D

signal onDeath

var death_body = preload("res://death_body.tscn")
var death_backpack = preload("res://death_backpack.tscn")

@onready var _graphics = $Graphics
@onready var _wheel1 = $VehicleWheel3D
@onready var _wheel2 = $VehicleWheel3D2

@export var _spawnpoints: Node3D
@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 125 # max horsepower
const ENGINE_ACCEL = 40
@export var MAX_SPEED = 34.0
const SPEEDUNLOCKBONUS = 20.0
@export var _torquePower = 175 # "tilt" power
@export var COMSHIFT = 1 # how far from the center the center of mass shifts while tilting
@export var COMSHIFTACCEL = 0.1 # how fast the center of mass shifts when tilting
@export var JUMPFORCE = 50

const DEATHTIMER = 2.5

var _currentCenterOfMassShift: float = 0
var _speedVal = 0.0;
var _isGrounded = false

# POWERUPS
var _unlockedSpeed = false


var _lastDeathPos: Vector3 
var _lockBike = false

#enum {
	#COASTING,
	#DRIVING
#}

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# - SPEED CAP -
	#linear_velocity.clampf(0, 35.0)
	#linear_velocity = linear_velocity.clampf(-30.0, 30.0)
	var setVel = 0
	if (_unlockedSpeed):
		setVel = get_linear_velocity().clampf(-MAX_SPEED + SPEEDUNLOCKBONUS, MAX_SPEED + SPEEDUNLOCKBONUS)
	else:
		setVel = get_linear_velocity().clampf(-MAX_SPEED, MAX_SPEED)
	
	state.set_linear_velocity(setVel)
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
	#print(_isGrounded)
	
	# - GAS -
	var cycling = Input.get_axis("backward", "forward")
	checkCycleAnim(cycling)
	if not _lockBike and cycling:
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
	if (not _lockBike and tiltAxis != 0):
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

func determineRespawnPoint(deathPos: Vector3):

	var spawn
	var sps = _spawnpoints.get_children()
	spawn = sps[0]
	for sp in sps:
		#print("deathpos: ",deathPos.x)
		#print("curr sp: ",sp.get_global_position().x)
		if (deathPos.x > sp.get_global_position().x):
			spawn = sp.get_global_position()
	
	return spawn

func death():
	var dbinstance = death_body.instantiate()
	get_tree().root.add_child(dbinstance)
	dbinstance.global_position = global_position
	dbinstance.linear_velocity = linear_velocity
	
	var dbinstance2 = death_backpack.instantiate()
	get_tree().root.add_child(dbinstance2)
	dbinstance2.global_position = global_position
	
	_lockBike = true
	$Graphics.hide()
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	_lastDeathPos = get_global_position()
	var respawnPoint = determineRespawnPoint(_lastDeathPos)

	await get_tree().create_timer(DEATHTIMER).timeout
	
	_lockBike = false
	$Graphics.show()
	set_global_position(respawnPoint)
	rotation = Vector3.ZERO

func checkCycleAnim(axisValue):
	if _lockBike:
		$Graphics/Legs.stop()
		return
	
	if (axisValue > 0):
		$Graphics/Legs.play("Pedaling")
	elif (axisValue < 0):
		$Graphics/Legs.play_backwards("Pedaling")
	else:
		$Graphics/Legs.stop()

func checkTiltAnim(axisValue):
	if _lockBike:
		$Graphics/Coast.show()
		$Graphics/LeanBack.hide()
		$Graphics/LeanForward.hide()
		return
	
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

func _on_area_manager_area_entered(area: Powerup) -> void:
	if area.power_type == Powerup.POWER_TYPES.UNLOCKSPEED:
		_unlockedSpeed = true
		print("UNLOCK SPEED!!!")

func _on_area_manager_area_exited(area: Powerup) -> void:
	if area.power_type == Powerup.POWER_TYPES.UNLOCKSPEED:
		_unlockedSpeed = false
		print("LOCK SPEED!!! SLOWW!!")

func _on_area_manager_area_entered_trigger(area: Trigger) -> void:
	print("phart")
	if area.trigger_type == Trigger.TRIGGER_TYPES.DEEATH:
		death()
		
	elif area.trigger_type == Trigger.TRIGGER_TYPES.ENDGAME:
		_lockBike = true
		await get_tree().create_timer(5.0).timeout
		get_tree().change_scene_to_file("res://Screens/EndScreen.tscn")

func _on_area_manager_area_exited_trigger(area: Trigger) -> void:
	print("phartedd")
	
