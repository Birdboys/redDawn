extends CharacterBody3D


const SPEED = 8
const AIR_SPEED = 1
const JUMP_VELOCITY = 12
const MAX_SPEED = 15
const MAX_AIR_SPEED = 15
const MAX_GRAPPLE_SPEED = 25
const GROUND_FRICTION = .3
const AIR_FRICTION = 0.3
const GRAPPLE_FRICTION = 1
const GRAPPLE_STRENGTH = 0.25
const MAX_GRAPPLE_FORCE = 1
const GRAPPLE_RESET_TIME = 1.5
const GRAPPLE_CONNECT_TIME = 1.5
const GRAPPLE_CANCLE_HOP_STRENGTH = 10
const DASH_COOLDOWN = 3
const DASH_STRENGTH = 30
const SPRINT_MODIFIER = 1.5
const HEAD_TILT_MAX = 10
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 35

@onready var neck := $characterNeck
@onready var camera := $characterNeck/characterCam
@onready var sensitivity := 0.005
@onready var grapple := $characterNeck/characterCam/grappleRay
@onready var grapple_timer := $timers/grapple_timer
@onready var grapple_reset_timer := $timers/grapple_reset_timer
@onready var grapple_line := $grapple_node/grapple_line
@onready var grapple_node := $grapple_node
@onready var grappling = false
@onready var grapple_pos = null
@onready var grapple_og_length = null
@onready var can_grapple = true
@onready var can_dash = true
@onready var dash_timer := $timers/dash_timer
@onready var crosshair := $HUD/crosshair

func _physics_process(delta):
	move(delta)
	var has_grapple = grapple.get_collider()
	handleCrosshair(has_grapple != null)
	if Input.is_action_just_pressed("grapple"):
		if grappling:
			if grapple_pos.y > position.y:
				velocity += Vector3.UP * GRAPPLE_CANCLE_HOP_STRENGTH
			stopGrapple()
		elif can_grapple:
			if has_grapple:
				startGrapple(grapple.get_collision_point())
	if grappling:
		handleGrapple()
	move_and_slide()
	
func move(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		var new_velocity = Vector3(velocity.x, 0, velocity.z)
		new_velocity.x = direction.x * SPEED
		new_velocity.z = direction.z * SPEED
		if Input.is_action_pressed("sprint"):
			new_velocity *= SPRINT_MODIFIER
		#if is_on_floor() and new_velocity.length() > MAX_SPEED:
			#new_velocity = direction*MAX_SPEED
		velocity.x = new_velocity.x
		velocity.z = new_velocity.z
		
		velocity.x = move_toward(velocity.x, 0, GROUND_FRICTION)
		velocity.z = move_toward(velocity.z, 0, GROUND_FRICTION)
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			print("JUST JUMPED")
		if velocity.length_squared() > 0:
			$characterNeck/headAnim.play("head_bob")
		camera.fov = move_toward(camera.fov, 75, 2)
	else:
		if velocity.length() > 20:
			camera.fov = move_toward(camera.fov, clamp(75+velocity.length(),0,95), .5)
			75 + velocity.length()
		var new_velocity = velocity
		new_velocity += direction * AIR_SPEED
		if not grappling:
			var air_strafe_velocity = Vector3(new_velocity.x, 0, new_velocity.z)
			if air_strafe_velocity.length() > MAX_AIR_SPEED:
				new_velocity = velocity.move_toward(velocity.normalized()*MAX_AIR_SPEED, AIR_FRICTION)
				#new_velocity = velocity.normalized() * MAX_AIR_SPEED
			new_velocity.y -= gravity * delta
		velocity = new_velocity
		#camera.
	if Input.is_action_just_pressed("dash") and can_dash:# and not grappling:
		dash(direction)
		#velocity.move_toward(Vector3.ZERO, AIR_FRICTION)
	#print(velocity.length())
func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * sensitivity)
			camera.rotate_x(-event.relative.y * sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(85))

func _on_grapple_timer_timeout():
	stopGrapple()
	pass # Replace with function body.

func startGrapple(pos):
	print("STARTING GRAPPLE: ", pos)
	grappling = true
	grapple_pos = pos + (pos-global_position).normalized()
	grapple_og_length = (grapple_pos-global_position).length()
	grapple_timer.start(GRAPPLE_CONNECT_TIME)
	can_grapple = false
	grapple_node.visible = true
	
func stopGrapple():
	grappling = false
	grapple_pos = null
	grapple_timer.stop()
	grapple_reset_timer.start(GRAPPLE_RESET_TIME)
	grapple_node.visible = false
	print("ENDING GRAPPLE")

func handleGrapple():
	var grapple_direction = grapple_pos - global_position
	var grapple_length = grapple_direction.length() #- grapple_og_length
	var grapple_force = clamp(GRAPPLE_STRENGTH * grapple_length/2, 0, MAX_GRAPPLE_FORCE)
	var new_velocity = velocity + grapple_force * grapple_direction.normalized()
	if new_velocity.length() > MAX_GRAPPLE_SPEED:
		new_velocity = velocity.move_toward(new_velocity.normalized()*MAX_GRAPPLE_SPEED, GRAPPLE_FRICTION*new_velocity.length())
	velocity = new_velocity
	grapple_node.look_at(grapple_pos, Vector3.UP)
	grapple_line.mesh.height = grapple_length + 1
	#grapple_line.translation.z = grapple_length / -2
	pass

func handleCrosshair(has_grapple):
	if can_grapple:
		if has_grapple:
			crosshair.setState(Crosshair.state.HAS_TARGET)
		else:
			crosshair.setState(Crosshair.state.CAN_GRAPPLE)
	elif grappling:
		crosshair.setState(Crosshair.state.HAS_TARGET)
	else:
		crosshair.setState(Crosshair.state.NO_GRAPPLE)
		
func dash(direction):
	print("JUST DASHED")
	can_dash = false
	camera.fov
	dash_timer.start(DASH_COOLDOWN)
	if direction == Vector3.ZERO:
		velocity = Vector3.UP * DASH_STRENGTH /2
	else:
		velocity = direction * DASH_STRENGTH
		
func resetGrapple():
	print("RESETING GRAPPLE")
	can_grapple = true

func _on_grapple_reset_timer_timeout():
	resetGrapple()
	pass # Replace with function body.

func _on_dash_timer_timeout():
	can_dash = true
	pass # Replace with function body.
