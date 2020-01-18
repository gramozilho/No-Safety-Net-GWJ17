extends "res://Skeleton.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func update_sprites():
	pass # Replace with function body.

func set_hand_to(hand_destination):
	var base_to_target = global_position.distance_to(hand_destination) * 2
	var ang_to_target = hand_destination.angle_to_point(global_position)
	if base_to_target >= len_upper + len_lower:
		$Joint0.rotation = ang_to_target
		$Joint0/Joint1.rotation = 0
	elif base_to_target < 10:
		pass
	else:
		var unique_angle = max(acos( -(pow(base_to_target, 2) - pow(len_upper, 2) - pow(len_lower, 2) ) / (2*len_upper*len_lower) ), 0.1)
		var alpha = (PI - unique_angle)/2
		if !right_side:
			$Joint0.rotation = ang_to_target - alpha
			$Joint0/Joint1.rotation = PI - unique_angle
		else:
			$Joint0.rotation = ang_to_target + alpha
			$Joint0/Joint1.rotation = PI + unique_angle

