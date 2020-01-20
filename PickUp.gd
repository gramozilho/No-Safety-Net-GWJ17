extends Area2D

var rgb_idx
var value = 1
signal pickup

#const UPPER_LIMIT = 255
const UPPER_LIMIT = 186
#const LOWER_LIMIT = 53
const LOWER_LIMIT = 75
const limit_array = [LOWER_LIMIT, UPPER_LIMIT]

const ALIVE_TIME = 20
const DESPAWN_TIME = 10

func _ready():
	random_color()
	$Timer.wait_time = ALIVE_TIME
	$Timer.start()

func random_color():
	$Sprite.modulate = Color(22.0/255.0, (randi()%111+75)/255.0, 30/255.0, .8)

func random_color_old():
	rgb_idx = randi()%3
	var this_color = [] 
	for i in range(3):
		# Interval range
		if rgb_idx == i:
			this_color.append(randi()%(UPPER_LIMIT-LOWER_LIMIT)+LOWER_LIMIT)
		# On or off color
		else:
			this_color.append(limit_array[randi()%2])
	print(this_color)
	$Sprite.modulate = Color(this_color[0]/255, this_color[1]/255, this_color[2]/255, .8)


func _on_PickUp_body_entered(body):
	print(body.name)
	if body.is_in_group('player'):
		emit_signal('pickup')
		queue_free()


func _on_Timer_timeout():
	var initial_color = $Sprite.modulate
	var final_color = initial_color
	final_color[3] = 0
	$Tween.interpolate_property($Sprite, 'modulate', initial_color, final_color, DESPAWN_TIME, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Tween_tween_completed(object, key):
	queue_free()


func _on_PickUp_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.name == 'Hand':
		emit_signal('pickup')
		queue_free()
