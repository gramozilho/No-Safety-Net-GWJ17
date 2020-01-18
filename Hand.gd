extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$T/Finger5.set_hand_to($T/Finger5.global_position + Vector2(20, 20))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
