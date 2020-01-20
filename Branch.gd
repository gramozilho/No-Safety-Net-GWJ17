extends RigidBody2D

signal branch_hit

func _on_Boulder_body_entered(body):
	if body.is_in_group('player'):
		emit_signal('branch_hit')

func freed():
	pass
