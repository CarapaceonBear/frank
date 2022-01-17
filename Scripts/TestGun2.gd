extends Spatial

func _ready():
	pass

func shoot():
	if Input.is_action_just_pressed("fire"):
		print("Gun2 fired")
