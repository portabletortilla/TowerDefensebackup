extends StaticBody2D

var bullet = preload("res://Towers/Fire/firebullet.tscn")

@export var damage = 5 
@export var maxHealth = 50.0
@export var health  = maxHealth
#Firerate
@export var Baserps = 0.5
var rps
#Regeneration factor for towers
@export var hps = 0.2
@export var currentRange = 1.0
@export var value = 15
@export var type = 1
@onready var sellValue = value

var rangeLevel
#If its currently searching for enemies
var active

#Current enemies in range of tower
var currTargets = [] 

#Target tower is aiming
var target

#tempTower.get_node("Tower/CollisionShape2D").shape.radius= TowerBaseR * Global.windTowerRadiusM
#Start tower in passive state 
func _ready():
	
	rangeLevel= currentRange
	health = maxHealth
	active=0
	rps = Baserps* Global.rpsMultplier
	#set_price_values()
	self.get_node("TimerNode/AttackTimer/Timer").wait_time = (1.0/rps)
	self.get_node("HealthComponent/healthBar").setup()
	self.update_sell_price()
	
func update_sell_price():
	sellValue = value * Global.sellRatio
	self.get_node("UpgradeNode/Panel/Special/Scrap/p").text = str(sellValue)	
#func set_price_values():
	#for i in range(1,4):
		#get_node("UpgradeNode/Panel/HBox/Upgrade" +str(i) + "/p").text= str(5)
	#pass
	
func _physics_process(_delta):
	if health <= 0 :
		Global.playerScoreP -= 1.25 * self.value
		self.queue_free()
		
	if is_instance_valid(target):
		self.look_at(target.position)

			
#Tower detects something
func _on_tower_body_entered(body):
	if "Enemy" in body.name and active == 0 :
		active = 1
		self.get_node("TimerNode/AttackTimer/Timer").start()
		attack_enemy_in_sight()
		

func _on_attack_timer_timeout():
	#print(self.get_node("AttackTimer").wait_time)
	if(active==1):
		attack_enemy_in_sight()
	
#targets farthest enemy i range
func attack_enemy_in_sight():
	var tempArray = []
	var currTarget = null	
	var currDist = 0
	var j
	while(true):
		currTargets = get_node("Tower").get_overlapping_bodies()
		#print(currTargets)
		#print(currTargets.size())
		#List has always the element self so we take that into account
		if currTargets.size()==0:
			#print("Didn't find enemies in range, hibernating tower")
			active=0
			self.get_node("TimerNode/AttackTimer/Timer").stop()
			return
			
		for i in currTargets:
			if "Enemy" in i.name:
				#print(i)
				tempArray.append(i)
				
		for i in tempArray:
			if currTarget == null:
				currTarget = i
				currDist = global_position.distance_to(i.position)
			else :
				j = global_position.distance_to(i.position)
				if j > currDist:
					currTarget = i
					currDist = j
		
		target = currTarget
		#safeguard
		if(target!=null):
			self.look_at(target.position)	
			var tempBullet = bullet.instantiate()
			tempBullet.bulletDamage = damage
			tempBullet.target = target	
			await get_tree().process_frame
			get_node("BulletContainer").add_child(tempBullet)
			tempBullet.global_position = $Aim.global_position	
			return
		


func _click_tower(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_mask == 1 :
		var towerPath = get_tree().get_root().get_node("SceneHandler/Map"+str(Global.currLevel)+"/Towers")
		for i in towerPath.get_child_count():
			if towerPath.get_child(i).name != self.name:
				towerPath.get_child(i).get_node("UpgradeNode/Panel").hide()
		update_sell_price()		
		self.get_node("UpgradeNode/Panel").global_position = self.global_position + Vector2(40,80)
		self.get_node("UpgradeNode/Panel").visible = !self.get_node("UpgradeNode/Panel").visible

func scrap():
	Global.currency += sellValue
	
	var aux = Global.srDegradation[Global.currLevel]
	if Global.sellRatio - aux <= 0.5:
		Global.sellRatio = 0.5
	else:
		Global.sellRatio -= aux	
	
	get_tree().get_root().get_node("SceneHandler/Map"+str(Global.currLevel)).updateScore()
		
	self.queue_free()
	
#Level up damage
@warning_ignore("unused_parameter")
func _on_upgrade_1_pressed(_path):
	var pPath = "UpgradeNode/Panel/HBox/Upgrade1/p"
	var price = int(self.get_node(pPath).text)
	if(canBuy(price)):
		damage = damage * 2
		Global.currency -= price
		value += price
		update_sell_price()
		get_node(pPath).text = str(price*2)
		
		get_tree().get_root().get_node("SceneHandler/Map"+str(Global.currLevel)).updateScore()
		
		if(Global.eventLock != 1 and randf_range(0,1.0) < Global.eventChance):
			Global.eventLock = 1
			get_parent().get_parent().beginEvent()
	else:
		print("Nope, not enough money")

#Level up Range
func _on_upgrade_2_pressed(_path):
	var pPath = "UpgradeNode/Panel/HBox/Upgrade2/p"
	var price = int(self.get_node(pPath).text)
	if(canBuy(price)):
		rangeLevel += 0.3
		self.get_node("Tower/Collision").scale = Vector2(rangeLevel,rangeLevel)
		self.get_node("Tower/Area").scale = Vector2(rangeLevel,rangeLevel)
		self.get_node("Tower/AreaUpgraded").scale = Vector2(rangeLevel+0.3,rangeLevel+0.3)
		Global.currency -= price
		value += price
		update_sell_price()
		get_node(pPath).text = str(price*2)
		get_node("Tower/AreaUpgraded").visible=false
		
		get_tree().get_root().get_node("SceneHandler/Map"+str(Global.currLevel)).updateScore()
		
		if(Global.eventLock != 1 and randf_range(0,1.0) < Global.eventChance):
			Global.eventLock = 1
			get_parent().get_parent().beginEvent()
			
	else:
		print("Nope, not enough money")
	
	
#Level up rps
func _on_upgrade_3_pressed(_path):
	var pPath = "UpgradeNode/Panel/HBox/Upgrade3/p"
	var price = int(self.get_node(pPath).text)
	if(canBuy(price)):
		Baserps+=1
		updateRPS()
		#self.get_node("TimerNode/AttackTimer/Timer").wait_time = (1.0/rps)
		Global.currency -= price
		value += price
		update_sell_price()
		get_node(pPath).text = str(price*2)
		
		get_tree().get_root().get_node("SceneHandler/Map"+str(Global.currLevel)).updateScore()
		
		if(Global.eventLock != 1 and randf_range(0,1.0) < Global.eventChance):
			Global.eventLock = 1
			get_parent().get_parent().beginEvent()
	else:
		print("Nope, not enough money")

func canBuy(price):
	return Global.currency - price >= 0



func _on_upgrade_2_mouse_entered():
	get_node("Tower/AreaUpgraded").visible=true
	


func _on_upgrade_2_mouse_exited():
	get_node("Tower/AreaUpgraded").visible=false

func getValue():
	return self.value

func _on_regen_timer_timeout():
	self.health += hps
	if self.health > self.maxHealth:
		self.health = self.maxHealth

func updateRPS():
	rps= Baserps * Global.rpsMultplier
	self.get_node("TimerNode/AttackTimer/Timer").wait_time = (1.0/rps)
