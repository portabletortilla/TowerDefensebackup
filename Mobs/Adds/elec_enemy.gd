extends BasicEnemy


#percentage of resources stolen
@export var pRS = 0.05
#Resources accomulated
@onready var eA = 0

func onTimerStealRes():
	var aux = ceil(Global.currency*pRS)
	Global.currency -= aux
	eA += aux
func death_effects():
	Global.currency += eA
	Global.playerScoreP += 0.5	
	#print("Yellow enemy killed, adding .5 points to score")
	
	if(Global.eventLock != 1 and randf_range(0,1.0) < Global.eventChance):
		Global.eventLock = 1
		get_parent().get_parent().beginEvent()
	self.queue_free()	
