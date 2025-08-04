extends Node

var carePackage = preload("res://Mobs/Drops/CarePackage.tscn")
var dictDuration = {0:10,
			1:20,
			2:20,
			3:20,
			4:20,
			5:30,
			6:30,
			7:45,
			8:180,
			9:60,}
var rng = RandomNumberGenerator.new()
 
func decideEvent():
	Global.eventLock = 1
	var modifier = [-1,1]
	var mod = 0
	rng.randomize()
	if(rng.randi_range(1,5) <= abs(3-Global.intensityValue)):
		mod = weighted_random(modifier)
		if((Global.PlayerRank + mod) not in range(1,5)):
			mod = 0
	var x = (Global.PlayerRank + mod - 1) * 2
	var y = x + rng.randi_range(0,1)
	print("Event id choosen: " + str(y) + " with mods : " +str(mod)+" and "+str(y-x))
	var z = [y,dictDuration[y]]
	return z 

func weighted_random(choices) -> int:
	var weights_sum := 0.0
	var a = (6-Global.PlayerRank)*(6-Global.intensityValue)
	var b = Global.PlayerRank*(Global.intensityValue - 1) 
	var weights= [a,b]
	for weight in weights:
		weights_sum += weight
	
	var r = rng.randi_range(0,weights_sum)
	if r <= weights[0]:
		return choices[0]
	else:
		return choices[1]
		
func event(eventId:int):
	var enemies = get_parent().get_node("Enemies").get_children()
	
	match eventId:
		0:
			var drops = get_parent().get_node("Drops")
			var g = carePackage.instantiate()
			var coords = get_viewport().size/2
			coords[0] += randi_range( coords[0] * -0.5, coords[0]* 0.5)
			coords[1] += randi_range( coords[1] * -0.5, coords[1]* 0.5)
			g.global_position = coords
			drops.add_child(g) 
		
		1: 
			Global.dropRate = 1.0
		
		2:
			var towers = get_parent().get_node("Towers").get_children()
			Global.rpsMultplier = 2
			for t in towers:
				t.updateRPS()
		
		3:
			Global.enemySpeedMultiplier= 0.5
			for e in enemies:
				e.update_stats(eventId)
		4:
			Global.enemyDmgMultiplier = 0.5
			for e in enemies:
				e.update_stats(eventId)
		5:
			Global.enemyDmgMultiplier = 1.15
			for e in enemies:
				e.update_stats(eventId)
		6:
			Global.enemyHpMultiplier=1.2
			for e in enemies:
				e.updateStats(eventId)
				
		7:	
			Global.enemySpeedMultiplier= 1.2
			for e in enemies:
				e.update_stats(eventId)
		8:
			Global.shieldAddition=1
			for e in enemies:
				e.update_stats(eventId)								
		9:
			Global.reviveAddition=1
			for e in enemies:
				e.update_stats(eventId)
