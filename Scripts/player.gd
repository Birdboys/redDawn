extends CharacterBody3D


const SPEED = 1
const AIR_SPEED = 0.25
const JUMP_VELOCITY = 6
const MAX_SPEED = 15
const GROUND_FRICTION = .3
const AIR_FRICTION = 0.3
const GRAPPLE_STRENGTH = 0.1
const MAX_GRAPPLE_FORCE = 3
const GRAPPLE_RESET_TIME = 3
const GRAPPLE_CONNECT_TIME = 0.3
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 15

@onready var neck := $characterNeck
@onready var camera := $characterNeck/characterCam
@onready var sensitivity := 0.005
@onready var grapple := $characterNeck/characterCam/grappleRay
@onready var grapple_timer := $timers/grapple_timer
@onready var grapple_reset_timer := $timers/grapple_reset_timer
@onready var grappling = false
@onready var grapple_pos = null
@onready var grapple_og_length = null
@onready var can_grapple = true
func _physics_process(delta):
	move(delta)
	if Input.is_action_just_pressed("grapple"):
		if grappling:
			stopGrapple()
		elif can_grapple:
			grapple.force_raycast_update()
			if grapple.get_collider():
				startGrapple(grapple.get_collision_point())

	if grappling:
		handleGrapple()
	move_and_slide()
	
func move(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		var new_velocity = Vector3(velocity.x, 0, velocity.z)
		new_velocity.x += direction.x * SPEED
		new_velocity.z += direction.z * SPEED
		if is_on_floor() and new_velocity.length() > MAX_SPEED:
			new_velocity = direction*MAX_SPEED
		velocity.x = new_velocity.x
		velocity.z = new_velocity.z
		
		velocity.x = move_toward(velocity.x, 0, GROUND_FRICTION)
		velocity.z = move_toward(velocity.z, 0, GROUND_FRICTION)
		
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
			print("JUST JUMPED")
	else:
		velocity.y -= gravity * delta
		velocity.x += direction.x * AIR_SPEED
		velocity.z += direction.z * AIR_SPEED
		
func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * sensitivity)
			camera.rotate_x(-event.relative.y * sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-30), deg_to_rad(60))

func _on_grapple_timer_timeout():
	stopGrapple()
	pass # Replace with function body.

func startGrapple(pos):
	print("STARTING GRAPPLE: ", pos)
	grappling = true
	grapple_pos = pos
	grapple_og_length = (grapple_pos-global_position).length()
	grapple_timer.start(GRAPPLE_CONNECT_TIME)
	can_grapple = false
	
func stopGrapple():
	grappling = false
	grapple_pos = null
	grapple_timer.stop()
	grapple_reset_timer.start(GRAPPLE_RESET_TIME)
	print("ENDING GRAPPLE")

func handleGrapple():
	var grapple_direction = grapple_pos - global_position
	var grapple_length = grapple_direction.length() #- grapple_og_length
	var grapple_force = clamp(GRAPPLE_STRENGTH * grapple_length, 0, MAX_GRAPPLE_FORCE)
	velocity += grapple_force * grapple_direction.normalized()
	pass

func resetGrapple():
	print("RESETING GRAPPLE")
	can_grapple = true

func _on_grapple_reset_timer_timeout():
	resetGrapple()
	pass # Replace with function body.
