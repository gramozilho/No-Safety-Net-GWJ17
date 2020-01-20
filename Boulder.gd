extends RigidBody2D


signal update_position
signal free
signal hit

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		emit_signal('update_position', global_position.x)

func freed():
	#print('Free boulder')
	emit_signal('free')
	queue_free()


func _on_Boulder_body_entered(body):
	pass # Replace with function body.
