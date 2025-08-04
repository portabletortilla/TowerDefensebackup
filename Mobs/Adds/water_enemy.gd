extends BasicEnemy

@export var regenRatio = 0.01


func onTimerRegen():
	if health + maxHealth*regenRatio > maxHealth:
		health = maxHealth
	else:
		health += maxHealth*regenRatio
			
func death_effects():
	Global.playerScoreP += 0.5	
	#print("Blue enemy killed, adding .5 points to score")
	
	if(Global.eventLock != 1 and randf_range(0,1.0) < Global.eventChance):
		Global.eventLock = 1
		get_parent().get_parent().beginEvent()
	self.queue_free()
		
