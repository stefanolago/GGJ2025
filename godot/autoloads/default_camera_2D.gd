extends Node

# This class is used to create a camera if there is none in the scene tree, centered at 0,0 instead of 
# having 0,0 as the upper left corner of the window

func _ready() -> void:
	# check if there is a camera in the scene tree
	var camera: Camera2D = get_viewport().get_camera_2d()
	if not camera:
		print("No camera found, creating one")
		# create a new camera
		camera = Camera2D.new()
		# add the camera to the scene
		add_child(camera)
		# center the camera at 0,0
		camera.global_position = Vector2.ZERO
		# set the camera to be the current camera
		camera.make_current()
	

	