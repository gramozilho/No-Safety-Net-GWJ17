extends Node2D

const skeleton = preload('res://Skeleton.tscn')
const arm = preload('res://Arm.tscn')
const leg = preload('res://Leg.tscn')
const hand = preload('res://Hand.tscn')

var dragBody = false
var target_pos = Vector2()
var original_pos = []
var body_center_displacement = Vector2()
var climbing_mode = true

# Arm object, is upper, is right, starting displacement
var arm_info = [[arm, true, true, Vector2(40, -30)], [arm, true, false, Vector2(-40, -60)], [leg, false, false, Vector2(30, 150)], [leg, false, true, Vector2(-25, 150)]]

func _ready():
	var i = 0
	for dock in $Docking.get_children():
		var new_arm = arm_info[i][0].instance()
		# Change individual params
		new_arm.upper_body = arm_info[i][1]
		if dock.is_in_group('grab'):
			new_arm.add_hand(hand)
		dock.add_child(new_arm)
		dock.get_children()[0].right_side = arm_info[i][2]
		dock.get_children()[0].set_hand_to(dock.global_position + arm_info[i][3])
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
			# Save original hand position
			original_pos = []
			for dock in $Docking.get_children():
				original_pos.append(dock.get_children()[0].get_hand_position())
			#Save distance from click to body center
			body_center_displacement = global_position - get_global_mouse_position()
			dragBody = true
	if event.is_action_pressed("ui_select"):
		climbing_mode = false


func _input(event):
	if dragBody and event.is_action_released("click_left"):
		print('Body Released')
		dragBody = false
		body_center_displacement = Vector2()
	if event is InputEventMouseMotion:
		# Target is mouse plus displacement from body center
		target_pos = get_global_mouse_position()
	if climbing_mode and event.is_action_pressed("ui_select"):
		climbing_mode = false
		falling_triggered()
	elif !climbing_mode and event.is_action_pressed("ui_select"):
		climbing_mode = true
		falling_untriggered()


func falling_triggered():
	print('Falling!')
	# Disable normal controls of left arm
	#$Docking/UpLeft.get_children()[0].climbing_mode = false
	#$Camera.global_position = $CameraNodeZoom.global_position
	#$Camera.zoom = Vector2(.25, .25)
	#print($CameraZoom.zoom)
	#$CameraZoom.current = true
	#$Camera.current = false
	#var tween = Tween.new()
	#add_child(tween)
	$Tween.interpolate_property($Camera, "global_position", $Camera.global_position, $CameraNodeZoom.global_position, .5,  Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Camera, "zoom", Vector2(1, 1), Vector2(.25, .25), .5,  Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	limb_visibility(false)


func falling_untriggered():
	print('Climbing!')
	#$Camera.global_position = $CameraNode.global_position
	#$Camera.zoom = Vector2(1, 1)
	$Tween.interpolate_property($Camera, "global_position", $Camera.global_position, global_position, .5,  Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Camera, "zoom", Vector2(.2, .2), Vector2(1, 1), .5,  Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	limb_visibility(true)


func limb_visibility(hide_limb):
	for dock in $Docking.get_children():
		if dock.is_in_group('hide'):
			dock.visible = hide_limb
			# TODO fade instead
			


func _process(delta):
	if climbing_mode and dragBody:
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
