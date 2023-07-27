extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	area.get_parent().position = Vector3(0,1,0)
	if area.get_parent().has_method("stopGrapple"):
		area.get_parent().stopGrapple()
	pass # Replace with function body.
