extends CanvasLayer

@export var restDuration = 20
@export var TowersHidden = false
signal newRound

func _ready():
	self.get_node("ProgressBar").visible = false
	updateRound()
	progress_bar_activate()

func set_n_rounds():
	self.get_node("Rounds").text = "Round 1/" + str(Global.nRounds)		
	
func progress_bar_activate():
	self.get_node("ProgressBar").visible = true
	self.get_node("ProgressBar").activate(restDuration)
	
func _process(_delta):
	self.get_node("HP").text = "HP : " + str(Global.health)	
	self.get_node("Currency").text = "Currency : " + str(snappedf(Global.currency,0.1))	

func hide_show_event(event):
	if event is InputEventMouseButton and event.button_mask == 1 :
		hide_show()
		

func hide_show():
	TowersHidden = !TowersHidden
	self.get_node("Show").visible = !self.get_node("Show").visible
	self.get_node("Hide").visible = !self.get_node("Hide").visible
	self.get_node("TowerSelection").visible = !self.get_node("TowerSelection").visible

func updateRound():
	get_node("Rounds").text = "Round " +str(Global.currentRound)+"/"+str(Global.nRounds)

func _new_round_timeout():
	Global.currentRound +=1
	updateRound()
	newRound.emit()

func _is_tower_hidden():
	return TowersHidden
