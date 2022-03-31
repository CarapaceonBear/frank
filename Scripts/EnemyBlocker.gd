extends StaticBody


func _ready():
	pass

func take_damage(value):
	get_parent().take_damage()
