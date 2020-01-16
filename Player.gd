extends Node2D

const skeleton = preload('res://Skeleton.tscn')
const arm = preload('res://Arm.tscn')
const leg = preload('res://Leg.tscn')

var dragBody = false
var target_pos = Vector2()
var original_pos = []
var body_center_displacement = Vector2()

var side_info = [true, false, false, true]
# Object, is right, starting angle
var arm_info = [[arm, true, -PI/4], [arm, true, -3*PI/4], [leg, false, -13*PI/8], [leg, false, -11*PI/8]]

func _ready():
	var i = 0
	for dock in $Docking.get_children():
		var new_arm = arm_info[i][0].instance()
		# Change individual params
		new_arm.upper_body = arm_info[i][1]
		#new_arm.rotation = arm_info[i][2]
		# Add arm
		dock.add_child(new_arm)
		i += 1

func _on_Player_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click_left"):
		# If any limb pressed, ignore this body click
		var limb_pressed = false
		for dock in $Docking.get_children():
			if dock.get_children()[0].dragMouse:
				limb_pressed = true
		if !limb_pressed:
			print('Body Pressed')
			dragBody = true
			# Save original hand position
			original_pos = []
			for dock in $Docking.get_children():
				original_pos.append(dock.get_children()[0].get_hand_position())
			print(original_pos)
			#Save distance from click to body center
			body_center_displacement = global_position - get_global_mouse_position()

func _input(event):
	if dragBody and event.is_action_released("click_left"):
		print('Body Released')
		dragBody = false
		body_center_displacement = Vector2()
	if event is InputEventMouseMotion:
		# Target is mouse plus displacement from body center
		target_pos = get_global_mouse_position()
		
		
func _process(delta):
	if dragBody:
		# Assure no limb is at its limit
		var limb_limit = false
		for dock in $Docking.get_children():
			if dock.get_children()[0].is_close_to_limit() and !dock.get_children()[0].is_in_this_direction(global_position, target_pos + body_center_displacement):
				limb_limit = true
		if !limb_limit:
			#var displacement = target_pos - global_position
			# move player
			global_position = target_pos + body_center_displacement
			# Return hands to position
			var i = 0
			for dock in $Docking.get_children():
				dock.get_children()[0].set_hand_to(original_pos[i])
				i += 1
			#for dock in $Docking.get_children():
			#	var limb = dock.get_children()[0]
			#	limb.set_hand_to(limb.global_position - displacement)
