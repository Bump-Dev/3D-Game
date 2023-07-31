extends CharacterBody3D

const SPEED = 8.0
const JUMP_VELOCITY = 8.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity := 0.004

@onready var mesh := $Mesh
@onready var camera := $Mesh/Camera3D
@onready var interaction := $Mesh/Camera3D/Interaction
@onready var hand := $Mesh/Camera3D/Hand
@onready var joint := $Mesh/Camera3D/Generic6DOFJoint3D
@onready var staticbody := $Mesh/Camera3D/StaticBody3D

@onready var outline_mat := preload("res://assets/materials/outline_mat.tres")
@onready var highlight_mat := preload("res://assets/materials/hightlight_mat.tres")

var picked_object:RigidBody3D
var pull_strength := 5
var rot_strength := 0.2
var throw_strength := 175
var locked := false

func _ready():
	if !is_multiplayer_authority(): return
	camera.current = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _unhandled_input(event):
	if !is_multiplayer_authority(): return
	
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED && !locked:
		rotate_head(event)
	
	if Input.is_action_just_pressed("interact"):
		var collider = interaction.get_collider()
		if collider != null:
			if collider.is_in_group("interactable"):
				collider.interact()
		
	if Input.is_action_just_pressed("pickup"):
		if picked_object == null:
			pickup_object()
		else:
			drop_object()
	if Input.is_action_pressed("rotate"):
		locked = true
		rotate_object(event)
	if Input.is_action_just_released("rotate"):
		locked = false
	if Input.is_action_just_pressed("throw"):
		if picked_object != null:
			var kb = picked_object.position - position
			picked_object.apply_central_force(kb*throw_strength)
			drop_object()

func _physics_process(delta):
	if !is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (mesh.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a)*pull_strength)

func rotate_head(event):
	if event is InputEventMouseMotion:
		mesh.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func rotate_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			staticbody.rotate_x(deg_to_rad(event.relative.y * rot_strength))
			staticbody.rotate_y(deg_to_rad(event.relative.x * rot_strength))

func pickup_object():
	var collider = interaction.get_collider()
	if collider != null && collider is RigidBody3D:
		picked_object = collider
		joint.set_node_b(picked_object.get_path())
		picked_object.get_node("MeshInstance3D/Outline").set_surface_override_material(0,highlight_mat)

func drop_object():
	if picked_object != null:
		picked_object.get_node("MeshInstance3D/Outline").set_surface_override_material(0,outline_mat)
		picked_object = null
		joint.set_node_b(joint.get_path())


