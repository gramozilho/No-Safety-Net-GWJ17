extends Node2D

export (bool) var right_side = true
export (bool) var upper_body = true

var dragMouse = false

var len_upper = 0
var len_lower = 0
var target_pos = Vector2()
var ang_to_target = 0

var climbing_mode = true

func _ready():
	len_upper = round($Joint0/Joint1.position.x)
	len_lower = round($Joint0/Joint1/Joint2.position.x)
	#update_sprites()
	load_sprites()

func load_sprites():
	pass


func _process(delta):
	if dragMouse:
		var current_pos = $Joint0/Joint1/Joint2.global_position
		var dist_to_target = current_pos.distance_to(target_pos)
		var base_node
		if is_in_group('finger'):
			base_node = get_parent().get_parent().get_parent()
			print(base_node.name)
			print(base_node.name, base_node.global_rotation)
			set_hand_to(target_pos, base_node.global_rotation)
		else:
			base_node = get_parent().get_parent().get_parent()
			#print(base_node.name, base_node.ang_to_target)
			set_hand_to(target_pos, base_node.global_rotation)

func set_hand_to(hand_destination, base_rotation=0):
	var base_to_target = global_position.distance_to(hand_destination)
	ang_to_target = hand_destination.angle_to_point(global_position)
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
		#$Joint0/Joint1/Joint2.rotation = $Joint0.rotation
	# Reorient sprites if needed
	#print('move hand', $Joint0/Joint1/Joint2.global_position)
	
	if $Joint0/Joint1/Joint2.global_position.x > global_position.x:
		right_side = upper_body
	else:
		right_side = !upper_body
	#print(self.name, ' is right side? ', right_side, '. Is upper body? ', upper_body)
	update_sprites()

func _input(event):
	if dragMouse and event.is_action_released("click_left"):
		print('Hand Released')
		dragMouse = false
	if event is InputEventMouseMotion:
		target_pos = get_global_mouse_position()


func _on_Hand_input_event(viewport, event, shape_idx):
	if climbing_mode:
		if event.is_action_pressed("click_left"):
			print('Hand Pressed!')
			dragMouse = true

func get_hand_position():
	return $Joint0/Joint1/Joint2.global_position

func is_close_to_limit():
	var joint_deg = int(round(rad2deg($Joint0/Joint1.rotation))) 
	if ((joint_deg > 358) or (joint_deg < 2)):
		return true
	return false

func is_in_this_direction(base, new_base):
	if base.distance_to($Joint0/Joint1/Joint2.global_position) >= new_base.distance_to($Joint0/Joint1/Joint2.global_position):
		return true
	return false

func update_sprites():
	var hand_location = $Joint0/Joint1/Joint2.global_position
	$Joint0/UpperSprite.flip_v = !right_side
	$Joint0/Joint1/LowerSprite.flip_v = !right_side

func add_hand(hand):
	var new_hand = hand.instance()
	$Joint0/Joint1/Joint2.add_child(new_hand)

func decrease_hand():
	$Joint0/Joint1/Joint2/Hand/HandCollision.scale *= Vector2(0.5, 0.5)
	$Joint0/Joint1/Joint2/Hand/HandSprite.scale *= Vector2(0.5, 0.5)
