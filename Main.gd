extends Node2D

const pickup = preload('res://PickUp.tscn')
const boulder = preload('res://Boulder.tscn')
const ex_sign = preload('res://Exclamation.tscn')
const branch = preload('res://Branch.tscn')

signal crash

var first_scene = true

var climbing = true
var crashed = false
var new_score
var total_score = 0
var hands_mode = false
var play_once = true


const SPAWN_WINDOW = [[300, 4800], [300, 2700]]

var help_text = "Clean vegetation to earn money. Spend this money on body upgrades.\nAvoid falling rocks and the edges of the screen\n\nInstructions:\n- LEFT MOUSE (click) on shop to spend money.\n- LEFT MOUSE (click and drag) to move player body, hands and feet (red circles)\n- RIGHT MOUSE (click and drag) to jump from mouse to character direction.\n  Release to jump and LEFT click to land\n- Press H to show/hide this help text"
var help_text_h = "Clean vegetation to earn money. Spend this money on body upgrades.\nAvoid falling rocks and the edges of the screen\n\nInstructions:\n- LEFT MOUSE (click) on shop to spend money.\n- LEFT MOUSE (click and drag) to move player body, hands and feet (red circles)\n- RIGHT MOUSE (click and drag) to jump from mouse to character direction.\n  Release to jump and LEFT click to land\n- Press U to zoom in/out of hand\n- Press H to show/hide this help text"
var help_text_1 = "Clean vegetation to earn money. Spend this money on body upgrades.\nAvoid falling rocks and the edges of the screen\n\nInstructions:\n- LEFT MOUSE (click) on shop to spend money.\n- LEFT MOUSE (click and drag) to move player body, hands and feet (red circles)\n- Press H to show/hide this help text"


func _ready():
	rand_seed(2)
	$MenuFirst.visible = true
	$FirstScene.visible = true
	$Menu.visible = false
	$Menu/Help.visible = false
	$MenuFirst/Help1.visible = true
	$MenuFirst/Start.visible = false
	$Player.global_position = $PlayerSpawn.global_position
	$FirstScene/TreeBg/FirstScene/CollisionPolygon2D.disabled = false
	$FirstScene/TreeBg/BranchArea/CollisionShape2D.disabled = false
	$Shop.visible = false
	$Menu/Help.text = help_text_1
	$BG_1.play()

func _input(event):
	if event.is_action_pressed("reset"):
		reset_player_and_game()
	if event.is_action_pressed("help"):
		if first_scene:
			$MenuFirst/Help1.visible = !$MenuFirst/Help1.is_visible()
		else:
			$Menu/Help.visible = !$Menu/Help.is_visible()
	if !crashed and climbing and event.is_action_pressed("hands_mode") and hands_mode:
		climbing = false
		$Tween.interpolate_property($Camera2D, "global_position", $Camera2D.global_position, $Player/CameraNodeZoom.global_position, 1,  Tween.TRANS_QUAD, Tween.EASE_IN)
		$Tween.interpolate_property($Camera2D, "zoom", Vector2(5, 5), Vector2(.5, .5), 1,  Tween.TRANS_QUAD, Tween.EASE_IN)
		$Tween.start()
		$Player/Docking/UpLeft.get_children()[0].show_hand()
	elif !crashed and !climbing and event.is_action_pressed("hands_mode") and hands_mode:
		climbing = true
		$Tween.interpolate_property($Camera2D, "global_position", $Camera2D.global_position, Vector2(0, 0), 1,  Tween.TRANS_QUAD, Tween.EASE_IN)
		$Tween.interpolate_property($Camera2D, "zoom", Vector2(.5, .5), Vector2(5, 5), 1,  Tween.TRANS_QUAD, Tween.EASE_IN)
		$Tween.start()
		$Player/Docking/UpLeft.get_children()[0].hide_hand()


func _on_Player_jump(pos):
	print('Jumpo from ', pos)


func _on_Boundaries_body_entered(body):
	if body.is_in_group('player'):
		if !crashed and !$Player.crashing:
			print('Player crashed')
			emit_signal('crash', ($CrashCoord.global_position - body.global_position).normalized())
			crashed = true
			$Menu/Restart.visible = true
	elif body.is_in_group('bad'):
		#print('Free body ', body.name)
		body.freed()


func _on_Restart_pressed():
	reset_player_and_game()
	$Button.play()
	
	#get_tree().reload_current_scene()

func handle_pickup():
	$Pickup.play()
	if $BoulderSpawn.is_stopped():
		$BoulderSpawn.start()
	#print('Score: ', score)
	total_score += 1
	#var keyword = ""
	$Menu/Score.text = "Money: " + str(total_score)
	#if total_score == 0:
	#	$Menu/Score.text = "Money: none"
	#elif total_score == 1:
	#	$Menu/Score.text = "You have 1 coin"
	#else:
	#	$Menu/Score.text = "You have " + str(total_score) + " coins"

func spawn_pickup_at(x, y):
	var location = Vector2(x, y)
	var new_pickup = pickup.instance()
	new_pickup.global_position = location
	new_pickup.connect("pickup", self, "handle_pickup")
	$Garage.add_child(new_pickup)

func spawn_boulder(x, y):
	var location = Vector2(x, y)
	var new_boulder = boulder.instance()
	var new_sign = ex_sign.instance()
	new_boulder.global_position = location
	new_sign.global_position.x = location.x
	new_boulder.connect("update_position", new_sign, "update_position")
	new_boulder.connect("free", new_sign, "free")
	$Garage.add_child(new_boulder)
	$Garage.add_child(new_sign)

func _on_ThingSpawn_timeout():
	#print('New spawn')
	#print(randf()*(SPAWN_WINDOW[0][1]-SPAWN_WINDOW[0][0]), randf()*(SPAWN_WINDOW[1][1]-SPAWN_WINDOW[1][0]))
	spawn_pickup_at(randf()*(SPAWN_WINDOW[0][1]-SPAWN_WINDOW[0][0]), randf()*(SPAWN_WINDOW[1][1]-SPAWN_WINDOW[1][0]))
	
func reset_player_and_game():
	$Menu.visible = true
	$ThingSpawn.start()
	$Player.dragBody = false
	$Player.climbing_mode = true
	$Player.charging_mode = false
	$Player.jumping = false
	$Player.falling = false
	$Player.crashing = false
	$Player.global_position = $PlayerSpawn.global_position
	$Player.rotation = 0
	# Erase all spawned objects
	for obj in $Garage.get_children():
		obj.queue_free()
	# reset lim position
	$Player.reset_limbs()
	$Shop.visible = false
	$Player.z_index = 0
	if play_once:
		play_once = false
		$BG_1.stop()
		$Ambulance.stop()
		$BG.play()
	$Menu/Help.visible = true

func stop_game_loop():
	$ThingSpawn.stop()
	emit_signal('crash', Vector2(0, 1))
	# Erase all spawned objects
	for obj in $Garage.get_children():
		obj.queue_free()

func _on_Shop_pressed():
	#emit_signal('crash', Vector2(0, 1))
	if !$Shop.is_visible_in_tree():
		stop_game_loop()
		$Shop.visible = true
		$Player.z_index = -1
		$Shop.update_money(total_score)
		$Button.play()
		$Shop/VBoxContainer2/Feedback.text = ""

func _on_FirstScene_body_entered(body):
	if body.is_in_group('player'):
		first_scene_drop()


func first_scene_drop():
	print('First scene drop')
	first_scene = false
	$MenuFirst/Start.visible = true
	var center_direction
	if $Player.global_position.x > 2500:
		center_direction = Vector2(.1, .5)
	else:
		center_direction = Vector2(-.1, .5)
	$Player._on_Main_crash(center_direction)
	var first = ""
	#if $Player.global_position.y > 2000:
	#	first = "You fell from the tree at an embarrassingly low altitue.\nEverybody saw. They say you weren't even trying to go up. Or are you just that clumsy?"
	#$MenuFirst/Help1.text = "You fell from the tree and hurt yourself really bad, injuring all your arms and legs. All yout limbs are now prosthetics.\nYou can still fall, but since these limbs are now quite durable you can never break them.\n\nWith this new found durability you become a professional cleaner for rock-climbing. Collect enought rubbish and  , '.\nYou become a \n\nTL;DR: Collect objects to earn cash. Spend cash on body upgrades."
	$MenuFirst/Help1.text = "You fell from the tree and hurt yourself really bad.\nAll your arms and legs are injuried and have been replaced by prosthetics.\nNo matter how hard the fall, these limbs are now indestructible.\n\nWith this newfound durability you get a job cleaning vegetation off rock climbing walls.\nClean enough and you might just be able to afford fancier limbs.\n\n\nTL;DR: Collect objects to earn cash. Spend cash on body upgrades.\nPress H to show/hide help"
	$Ambulance.play()
	$BG_1.volume_db -= 10

func _on_Start_pressed():
	reset_player_and_game()
	$MenuFirst.visible = false
	$FirstScene.visible = false
	$FirstScene/TreeBg/FirstScene/CollisionPolygon2D.disabled = true
	$FirstScene/TreeBg/BranchArea/CollisionShape2D.disabled= true
	$Button.play()


func _on_BranchArea_body_entered(body):
	if first_scene and body.is_in_group('player'):
		var location = Vector2($Player.global_position.x, -150)
		var new_branch = branch.instance()
		new_branch.global_position = location
		new_branch.connect("branch_hit", self, "branch_hit")
		$FirstScene.add_child(new_branch)

func branch_hit():
	first_scene_drop()


func _on_BoulderSpawn_timeout():
	spawn_boulder(randf()*(SPAWN_WINDOW[0][1]-SPAWN_WINDOW[0][0]), -randf()*(SPAWN_WINDOW[1][1]-SPAWN_WINDOW[1][0]))


func _on_Shop_buy(money):
	total_score = money
	$Menu/Score.text = "Money: " + str(total_score)

func activate_hands():
	hands_mode = true
	$Menu/Help.text = help_text_h

func jump_help():
	$Menu/Help.text = help_text
	$ThingSpawn.wait_time = 3
	$BoulderSpawn.wait_time = 4

func jump_infinite():
	$Menu/Help.text = help_text
	$ThingSpawn.wait_time = 2
	$BoulderSpawn.wait_time = 3
