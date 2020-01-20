extends StaticBody2D


const Y_COORD = 200

func _ready():
	global_position = Vector2(-500, Y_COORD)

func update_position(x):
	global_position.x = x

func free():
	queue_free()
