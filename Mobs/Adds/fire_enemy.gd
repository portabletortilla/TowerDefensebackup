extends BasicEnemy

@export var explosionDamage = 2 * damage

func death_effects():
	Global.playerScoreP += 0.5
	#print("Red enemy killed, adding .5 points to score")
	
	var explosion = get_node("Explosion")
	#Safety net for changes in damage
	explosionDamage = 2 * damage
	explode(explosion)
	if(Global.eventLock != 1 and randf_range(0,1.0) < Global.eventChance):
		Global.eventLock = 1
		get_parent().get_parent().beginEvent()
	get_node("ExplosionGif").play("d")	
	await get_node("ExplosionGif").animation_finished
	self.queue_free()
func explode(ex):
	#print(ex.get_overlapping_bodies())
	for i in ex.get_overlapping_bodies():
		i.health -= explosionDamage
	
