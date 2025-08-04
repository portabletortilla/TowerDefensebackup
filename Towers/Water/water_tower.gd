extends StaticBody2D



@export var damage = 10
@export var maxHealth = 50.0
@export var health  = maxHealth
#Firerate
@export var Baserps = 0.5
var reload
#Regeneration factor for towers
@export var hps = 0.0 
@export var currentRange = 1.0
@export var value = 30
@export var type = 3

var rangeLevel
@onready var sellValue = value
#If its currently locking on where to fire
var active
var loaded
var blocked=1
#Current enemies in range of tower
var currTargets = [] 

#Target tower is aiming
var target

#tempTower.get_node("Tower/CollisionShape2D").shape.radius= TowerBaseR * Global.windTowerRadiusM
#Start tower in passive state 
func _ready():
	rangeLevel = currentRange
	health = maxHealth
	active=0
	reload= Baserps * Global.rpsMultplier
	#set_price_values()
	self.get_node("TimerNode/AttackTimer/Timer").wait_time = (1.0/reload)
	self.get_node("TimerNode/AttackTimer/Timer").start()
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
	#Tower Death
	if health <= 0 :
		Global.playerScoreP -= 1.25 * self.value
		self.queue_free()
			
	if active:
		self.look_at(get_global_mouse_position())
			
			
func _on_reload_timer_timeout():
	loaded=1
	#print(get_node("UpgradeNode/Panel/Special/Fire").disabled)
	get_node("UpgradeNode/Panel/Special/Fire").disabled = false
	get_node("LoadedSprite").visible=true
	get_node("UnloadedSprite").visible=false
	#emit("ReadyButton") #Todo send signal to change button in upgrade screen
	

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

func getValue():
	return self.value
	
func fire(event):
	var disabled= get_node("UpgradeNode/Panel/Special/Fire").disabled
	var explosion = get_node("Explosion")
	var area = get_node("Explosion/Area")
	if event is InputEventMouseButton and event.button_mask == 1 and disabled == false:
		explosion.global_position = event.global_position + Vector2(0,20)
		area.visible= true
		#print("pressed")
		blocked=0
	elif event is InputEventMouseMotion and event.button_mask == 1 and blocked != 1:
		explosion.global_position = event.global_position + Vector2(0,20)
		active=1
		#print( event.global_position)
		
	elif event is InputEventMouseButton and event.button_mask == 0 and blocked != 1:
		explode(explosion,area)
		#"Explosion occurs"
		get_node("Explosion/AnimatedSprite2D").global_position = event.global_position + Vector2(0,20)
		get_node("Explosion/AnimatedSprite2D").global_rotation = 0
		get_node("Explosion/AnimatedSprite2D").play("explode")
		
		get_node("UpgradeNode/Panel/Special/Fire").disabled = true 
		get_node("LoadedSprite").visible=false
		get_node("UnloadedSprite").visible=true
		self.get_node("TimerNode/AttackTimer/Timer").start()
		blocked=1
		active=0
		#print("fired")

func explode(ex,area):
	for i in ex.get_overlapping_bodies():
		if "Enemy" in i.name:
			if i.shielding > 0 :
				i.shielding -= 1
				i.updateShield()
			else:
				i.takeDamage(damage)
	ex.global_position = self.global_position
	area.visible = false


			
#Level up damage
@warning_ignore("unused_parameter")
func _on_upgrade_1_pressed(_path):
	var pPath = "UpgradeNode/Panel/HBox/Upgrade1/p"
	var price = int(self.get_node(pPath).text)
	if(canBuy(price)):
		damage = damage * 2
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
		self.get_node("Explosion/AnimatedSprite2D").scale *= Vector2(rangeLevel,rangeLevel)
		self.get_node("Explosion/Collision").scale = Vector2(rangeLevel,rangeLevel)
		self.get_node("Explosion/Area").scale = Vector2(rangeLevel,rangeLevel)
		self.get_node("Explosion/AreaUpgraded").scale = Vector2(rangeLevel+0.3,rangeLevel+0.3)
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
	
	
#Level up rps
func _on_upgrade_3_pressed(_path):
	var pPath = "UpgradeNode/Panel/HBox/Upgrade3/p"
	var price = int(self.get_node(pPath).text)
	if(canBuy(price)):
		Baserps+=0.25
		updateRPS()
		self.get_node("TimerNode/AttackTimer/Timer").wait_time = (1.0/reload)
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
	
func update_sell_value(price):
		sellValue += price/Global.sellRatio
		value += price
		self.get_node("UpgradeNode/Panel/Special/Scrap/p").text = str(sellValue)

func _on_upgrade_2_mouse_entered():
	get_node("Explosion/AreaUpgraded").visible=true
	

func _on_upgrade_2_mouse_exited():
	get_node("Explosion/AreaUpgraded").visible=false

func _on_regen_timer_timeout():
	self.health += hps
	if self.health > self.maxHealth:
		self.health = self.maxHealth

func updateRPS():
	reload = Baserps * Global.rpsMultplier
	self.get_node("TimerNode/AttackTimer/Timer").wait_time = (1.0/reload)
