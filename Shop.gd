extends Control

var total_money
var current_signal
signal buy
signal upgrade
var current_cost

var upgrade_idx = 0
# Dict strucutre: price, description
var upgrade_list = {'price': [3, 5, 10, 20, 100, 10000],
		'text': ['Jump for the first time!\nCutting edge technology now allows us to create limbs flexible enough to be used for jumping. Requires a 5 second wait between uses. Click again to land.', 'Jump bigger distances!\nPick up some speed when jumping with the increased stregth of the new available limbs!', 'Infinite jumps!\nNo longer wait for for the next jump to charge. Make those hands and feet useless!', 'Hard as diamonds!\nBecome unstopable. Not even the screen window can hold you.', "Actual hands!\nReplace that leftie fingerless hand with a more complete one. Right hand out of stock.\n\nWarning: the previous feature is experimental and serves no real purpose. Seriously, it is pointless.", 'No more updates in stock. Thank you for being a valuable customer.\n\nGame made for the Godot Wild Jam #17.\n\n']}

# Called when the node enters the scene tree for the first time.
func _ready():
	set_upgrade()


func description(text, bname, cost):
	$Tooltip.text = text + ' Costs ' + str(cost) + '.'
	current_signal = bname
	#current_cost = cost

func _on_Buy_pressed():
	if total_money < current_cost:
		description("Not enough money for this item", current_signal, current_cost)
	else:
		total_money -= current_cost
		emit_signal("buy", current_signal, total_money)

func update_money(new_money):
	total_money = new_money


func _on_U1_pressed():
	if upgrade_idx < (len(upgrade_list['price'])-1):
		if total_money < upgrade_list['price'][upgrade_idx]:
			$VBoxContainer2/Feedback.text = "Not enough money for this purchase."
		else:
			$VBoxContainer2/Feedback.text = "Upgrade bought."
			total_money -= upgrade_list['price'][upgrade_idx]
			emit_signal('buy', total_money)
			upgrade_idx += 1
			set_upgrade()
	else:
		OS.shell_open("https://twitter.com/gramozilho")
	emit_signal("upgrade", upgrade_idx-1)

func set_upgrade():
	if upgrade_idx == (len(upgrade_list['price'])-1):
		$VBoxContainer2/U1.text = "Let me know what you think of the game (click for twitter link)"
	else:
		$VBoxContainer2/U1.text = "CLICK HERE TO UPGRADE NOW FOR " + str(upgrade_list['price'][upgrade_idx]) + " COINS"
	$VBoxContainer2/Description.text = upgrade_list['text'][upgrade_idx]
	
