extends CharacterBody3D


const SPEED = 4
const MAX_GRAPPLE_FORCE = 1.5
const GRAPPLE_SPRING_CONST = 0.25
const JUMP_VELOCITY = 10
const END_GRAPPLE_DIST = 2
const MAX_GROUND_SPEED = 10
const MAX_AIR_SPEED = 15 
const GROUND_FRICTION = 0.25
const AIR_SPEED = 0.2
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 30
@onready var neck := $characterNeck
@onready var camera := $characterNeck/characterCam
@onready var sensitivity := 0.005
@onready var sprinting := false
@onready var grapple := $characterNeck/characterCam/grappleRay
@onready var grapple_timer := $grapple_timer
@onready var grappling = false
@onready var grapple_pos = null
@onready var move_speed := 0.0
func _physics_process(delta):
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not grappling:
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("grapple"):
		if grappling:
			stopGrapple()
		else:
			grapple.force_raycast_update()
			if grapple.get_collider():
				startGrapple(grapple.get_collision_point())
			#print(grapple.get_collision_point(), grapple.get_collision_normal())
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	#var normalized_input_dir = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if grappling:
		var grappling_direction = (grapple_pos-neck.global_position).normalized()
		var distance = position.distance_to(grapple_pos)
		var grapple_force = (distance-5) * GRAPPLE_SPRING_CONST
		grapple_force = clamp(grapple_force, 0.0, MAX_GRAPPLE_FORCE)
		velocity += (grapple_force * distance) * grappling_direction.normalized()
		if distance <= END_GRAPPLE_DIST:
			stopGrapple()
	elif sprinting:
		pass
		
	
		# Add the gravity.
	if not is_on_floor():
		#print("applying_gravity")
		velocity.y -= gravity * delta
	#print("applying friction")
	if not grappling:
		if sprinting:
			velocity += direction*SPEED*1.25
		else:
			velocity += direction*SPEED
		velocity *= 1-GROUND_FRICTION
		print(velocity)
	move_and_slide()
func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("sprint"):
		sprinting = true
	elif event.is_action_released("sprint"):
		sprinting = false
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
	grapple_timer.start(2)
	
func stopGrapple():
	grappling = false
	grapple_pos = null
	grapple_timer.stop()
	print("ENDING GRAPPLE")
