class_name Player
extends KinematicBody

export var sensitivity : float = 0.05

var velocity : Vector3
var h_velocity : Vector3
var wish_dir : Vector3
var snap_vector : Vector3
var input_vector : Vector2

var is_crouching : bool

var just_landed : bool
var just_jumped : bool

var high_land : bool

const GRAVITY = 50.0
const MAX_ACCEL = 15.0
const MAX_CROUCHED_ACCEL = MAX_ACCEL / 1.5
const MAX_AIR_ACCEL = MAX_ACCEL * 0.55
const ACCEL = 215.0
const FRICTION = 6.5
const CROUCH_FRICTION = FRICTION * 3
const JUMP_HEIGHT = 20
const CROUCH_JUMP_HEIGHT = JUMP_HEIGHT * 6

const NORMAL_HEIGHT = 2.5
const CROUCH_HEIGHT = 1.5

var cur_air_accel : float
var cur_accel : float

var relative_mouse : Vector2
var bobbing_value : float

var control_speed : float = 20
var jump_height : float = JUMP_HEIGHT

onready var camera_holder := $CameraHolder
onready var camera := camera_holder.get_node("Camera")

onready var dust := $DustParticles

onready var mesh := $Pivot/MeshInstance

onready var collider := $Collider
onready var ceiling := $Ceiling

onready var velocity_label :=  $HUD/VelocityLabel
onready var debug_info := get_tree().current_scene.get_node("DebugUI/DebugInfo")

func _ready() -> void:
	debug_info.add_property(self, "velocity").add_property(self, "snap_vector")\
	.add_property(self, "global_transform:origin").add_property(self, "is_crouching")\
	.add_property(self, "just_jumped").add_property(self, "just_landed")

func _unhandled_input(event : InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			relative_mouse = event.relative

			camera_holder.rotate_y(deg2rad(-event.relative.x * sensitivity))
			camera.rotate_x(deg2rad(-event.relative.y * sensitivity))

			# Clamp rotation to prevent it from going over
			camera.rotation.x = clamp(camera.rotation.x,deg2rad(-90), deg2rad(90))

func _physics_process(delta) -> void:
	_handle_crouch(delta)
	_handle_movement(delta)

func _handle_movement(delta : float) -> void:
	var camera_holder_basis = camera_holder.global_transform.basis
	input_vector = Input.get_vector("left", "right", "forward", "backward")

	wish_dir = camera_holder_basis * Vector3(input_vector.x, 0, input_vector.y).normalized()

	just_landed = is_on_floor() && snap_vector == Vector3.ZERO
	just_jumped = is_on_floor() && Input.is_action_pressed("jump")

	if is_on_floor():
		velocity.y = 0.0 if !just_jumped else jump_height

		velocity = apply_friction(velocity, delta)
		velocity += accelerate(velocity, wish_dir, MAX_ACCEL if !is_crouching else MAX_CROUCHED_ACCEL, delta)

	else:
		if velocity.y < -45:
			high_land = true

		snap_vector = Vector3.ZERO

		velocity.y -= GRAVITY * delta

		velocity += accelerate(velocity, wish_dir, (MAX_AIR_ACCEL if !is_crouching else MAX_AIR_ACCEL * 1.3), delta)

	if just_jumped:
		snap_vector = Vector3.ZERO
	if just_landed:
		snap_vector = Vector3.DOWN

	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)
	h_velocity = velocity * Vector3(1, 0, 1)

	dust.emitting = true if is_on_floor() && (floor(abs(velocity.x)) || floor(abs(velocity.z)) != 0) else false
	bobbing_value += 15 * delta

func _handle_crouch(delta : float) -> void:
	var cam_lerp : float = 10
	var min_cam_y : float = -0.75
	var max_cam_y : float = 0.0

	$Pivot/MeshInstance.mesh.mid_height = collider.shape.height

	if Input.is_action_pressed("crouch") || (is_crouching && ceiling.is_colliding()):
		collider.shape.height = CROUCH_HEIGHT
		camera.transform.origin.y = lerp(camera.transform.origin.y, min_cam_y, cam_lerp * delta)

	elif !ceiling.is_colliding():
		collider.shape.height = NORMAL_HEIGHT
		camera.transform.origin.y = lerp(camera.transform.origin.y, max_cam_y, cam_lerp * delta)

	collider.shape.height = clamp(collider.shape.height, CROUCH_HEIGHT, NORMAL_HEIGHT)
	is_crouching = true if collider.shape.height < NORMAL_HEIGHT else false
	jump_height = CROUCH_JUMP_HEIGHT if ceiling.is_colliding() else JUMP_HEIGHT

	velocity.y = -GRAVITY / 3 if ceiling.is_colliding() else velocity.y

func apply_friction(input_velocity : Vector3, delta : float) -> Vector3:
	var _speed : float = input_velocity.length()
	var _scaled_velocity : Vector3

	if _speed != 0:
		var drop = _speed * (FRICTION if !is_crouching else CROUCH_FRICTION) * delta # Amount of _speed to be reduced by friction
		_scaled_velocity = input_velocity * max(_speed - drop, 0) / _speed

	if _speed < 0.5:
		return Vector3.ZERO

	return _scaled_velocity

func accelerate(input_velocity : Vector3, input_wish_dir : Vector3, max_accel : float, delta : float ) -> Vector3:
	var _l_velocity := Vector3(input_velocity.x, 0, input_velocity.z)
	var _cur_speed := _l_velocity.dot(input_wish_dir)
	var _cur_accel := clamp(max_accel - _cur_speed ,0, ACCEL * delta)

	return input_wish_dir * _cur_accel
