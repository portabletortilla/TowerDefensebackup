extends CanvasLayer

@export var restDuration = 20
@export var TowersHidden = false
signal newRound

func _ready():
	self.get_node("ProgressBar").visible = false
	updateRound()
	progress_bar_activate()

func set_n_rounds():
	get_node("RoundContainer/Values").text = "1/" + str(Global.nRounds)		
	
func progress_bar_activate():
	self.get_node("ProgressBar").visible = true
	self.get_node("ProgressBar").activate(restDuration)
	
func _process(_delta):
	self.get_node("HpContainer/Points").text = str(Global.health)	
	self.get_node("CurrencyContainer/Points").text = str(snappedf(Global.currency,0.1))
	self.get_node("ScoreContainer/Points").text = str("%06.1f" % Global.totalPlayerScore)	

func hide_show_event(event):
	if event is InputEventMouseButton and event.button_mask == 1 :
		hide_show()
		

func hide_show():
	TowersHidden = !TowersHidden
	self.get_node("Show").visible = !self.get_node("Show").visible
	self.get_node("Hide").visible = !self.get_node("Hide").visible
	self.get_node("TowerSelection").visible = !self.get_node("TowerSelection").visible

func updateRound():
	get_node("RoundContainer/Values").text = str(Global.currentRound)+"/"+str(Global.nRounds)

func updateBaseStats(info):
	get_node("BaseStatsContainer/Stats").text = str(info)
	
func _new_round_timeout():
	Global.currentRound +=1
	updateRound()
	newRound.emit()

func _is_tower_hidden():
	return TowersHidden


func _on_button_pressed():
	if(Global.currency>=10):
		Global.health+=1
		Global.currency-=10
