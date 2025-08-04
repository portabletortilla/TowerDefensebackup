extends StaticBody2D



@export var SDamage = 10
@export var SMaxHealth = 50.0
@export var health  = SMaxHealth
#Firerate
@export var SReload = 0.5
#Regeneration factor for towers
@export var SHps = 0.0 
@export var SCurrentRange = 1.0
@export var value = 40
@export var type = 3
var damage
var maxHealth
var reload
var hps
var rangeLevel
var sellValue
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
	
	damage = SDamage
	maxHealth = SMaxHealth
	reload = SReload
	hps=SHps
	rangeLevel=SCurrentRange
	health = maxHealth
	sellValue =20
	active=0
	#set_price_values()
	self.get_node("TimerNode/AttackTimer/Timer").wait_time = (1.0/reload)
	self.get_node("TimerNode/AttackTimer/Timer").start()
	self.get_node("HealthComponent/healthBar").setup()
	

#func set_price_values():
	#for i in range(1,4):
		#get_node("UpgradeNode/Panel/HBox/Upgrade" +str(i) + "/p").text= str(5)
	#pass
	
func _physics_process(_delta):
	#Tower Death
	if health <= 0 :
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
		self.get_node("UpgradeNode/Panel").global_position = self.global_position + Vector2(40,80)
		self.get_node("UpgradeNode/Panel").visible = !self.get_node("UpgradeNode/Panel").visible

	
func scrap():
	Global.currency += sellValue
	self.queue_free()

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
			i.health -= damage
	ex.global_position = self.global_position
	area.visible = false


			
#Level up damage
@warning_ignore("unused_parameter")
func _on_upgrade_1_pressed(_path):
	var pPath = "UpgradeNode/Panel/HBox/Upgrade1/p"
	var price = int(self.get_node(pPath).text)
	if(canBuy(price)):
		damage = damage * 2

		update_sell_value(price)
		get_node(pPath).text = str(price*2)
	else:
		print("Nope, not enough money")

#Level up Range
func _on_upgrade_2_pressed(_path):
	var pPath = "UpgradeNode/Panel/HBox/Upgrade2/p"
	var price = int(self.get_node(pPath).text)
	if(canBuy(price)):
		rangeLevel += 0.3
		self.get_node("Explosion/Collision").scale = Vector2(rangeLevel,rangeLevel)
		self.get_node("Explosion/Area").scale = Vector2(rangeLevel,rangeLevel)
		self.get_node("Explosion/AreaUpgraded").scale = Vector2(rangeLevel+0.3,rangeLevel+0.3)
		Global.currency -= price
		update_sell_value(price)
		get_node(pPath).text = str(price*2)
	else:
		print("Nope, not enough money")
	
	
#Level up rps
func _on_upgrade_3_pressed(_path):
	var pPath = "UpgradeNode/Panel/HBox/Upgrade3/p"
	var price = int(self.get_node(pPath).text)
	if(canBuy(price)):
		reload += 0.25
		self.get_node("TimerNode/AttackTimer/Timer").wait_time = (1.0/reload)
		Global.currency -= price

		update_sell_value(price)
		get_node(pPath).text = str(price*2)
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
