extends TextureRect
class_name Crosshair
enum state {CAN_GRAPPLE, HAS_TARGET, NO_GRAPPLE}
@onready var current_state = state.CAN_GRAPPLE
@onready var can_grapple := preload("res://Assets/crosshair_can_grapple.png")
@onready var has_target := preload("res://Assets/crosshair.png")
@onready var no_grapple := preload("res://Assets/crosshair_no_grapple.png")
# Called when the node enters the scene tree for the first time.
func _ready():
	setState(state.CAN_GRAPPLE)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#match current_state:
		#state.CAN_GRAPPLE: texture = can_grapple
		#state.HAS_TARGET: texture = has_target
		#state.NO_GRAPPLE: texture = no_grapple
	pass

func setState(s: state):
	current_state = s
	match s:
		state.CAN_GRAPPLE: texture = can_grapple
		state.HAS_TARGET: texture = has_target
		state.NO_GRAPPLE: texture = no_grapple
