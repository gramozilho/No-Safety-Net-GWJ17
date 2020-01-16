extends Node2D

var right_side = true
export (bool) var upper_body = true

var dragMouse = false

var len_upper = 0
var len_lower = 0
var target_pos = Vector2()

func _ready():
	len_upper = round($Joint0/Joint1.position.x)
	len_lower = round($Joint0/Joint1/Joint2.position.x)
	update_sprites()
	load_sprites()

func load_sprites():
	pass


func _process(delta):
	if dragMouse:
		var current_pos = $Joint0/Joint1/Joint2.global_position
		var dist_to_target = current_pos.distance_to(target_pos)
		#if dist_to_target < 5:
		set_hand_to(target_pos)
		#else:
		#	set_hand_to(current_pos.linear_interpolate(target_pos, 0.9))
	#	#set_hand_to(target_pos)
		#$Joint1/Joint2/Joint3/Hand.set_global_position(get_viewport().get_mouse_position())

func set_hand_to(hand_destination):
	var base_to_target = global_position.distance_to(hand_destination) * 2
	#print('b2t ', base_to_target, '    lens ', len_upper + len_lower)
	var ang_to_target = hand_destination.angle_to_point(global_position)
	#print('ang_to_target ', ang_to_target, '  distance to targ ', dist_to_target, '   glob pos', global_position, '   targ_pos ', target_pos)
	if base_to_target >= len_upper + len_lower:
		$Joint0.rotation = ang_to_target
		$Joint0/Joint1.rotation = 0
	elif base_to_target < 10:
		pass
	else:
		var unique_angle = acos( -(pow(base_to_target, 2) - pow(len_upper, 2) - pow(len_lower, 2) ) / (2*len_upper*len_lower) )
		var alpha = (PI - unique_angle)/2
		if !right_side:
			$Joint0.rotation = ang_to_target - alpha
			$Joint0/Joint1.rotation = PI - unique_angle
		else:
			$Joint0.rotation = ang_to_target + alpha
			$Joint0/Joint1.rotation = PI + unique_angle
	# Reorient sprites if needed
	if hand_destination.x > global_position.x:
		right_side = upper_body
	else:
		right_side = !upper_body
	update_sprites()

func _input(event):
	if dragMouse and event.is_action_released("click_left"):
		print('Hand Released')
		dragMouse = false
	if event is InputEventMouseMotion:
		target_pos = get_global_mouse_position()


func _on_Hand_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click_left"):
		print('Hand Pressed!')
		dragMouse = true

func get_hand_position():
	return $Joint0/Joint1/Joint2.global_position

func is_close_to_limit():
	var joint_deg = int(round(rad2deg($Joint0/Joint1.rotation))) 
	print(joint_deg)
	if ((joint_deg > 358) or (joint_deg < 2)):
		return true
	return false

func is_in_this_direction(base, new_base):
	if base.distance_to($Joint0/Joint1/Joint2.global_position) >= new_base.distance_to($Joint0/Joint1/Joint2.global_position):
		return true
	return false

func update_sprites():
	$Joint0/UpperSprite.flip_v = !right_side
	$Joint0/Joint1/LowerSprite.flip_v = !right_side

