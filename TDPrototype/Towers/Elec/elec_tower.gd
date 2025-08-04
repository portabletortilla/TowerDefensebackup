extends StaticBody2D


@export var SDamage = 5 
@export var SMaxHealth = 50.0
@export var health  = SMaxHealth
#Firerate
@export var SRps = 0.75
#Regeneration factor for towers
@export var SHps = 0.2
@export var SCurrentRange = 1.0
@export var value = 30
@export var type = 2
var damage
var maxHealth
var rps
var hps
var rangeLevel
var sellValue

#If its currently searching for enemies
var active

#Current enemies in range of tower
var currTargets = [] 

#Target tower is aiming
var target

#tempTower.get_node("Tower/CollisionShape2D").shape.radius= TowerBaseR * Global.windTowerRadiusM
#Start tower in passive state 
func _ready():
	
	damage = SDamage
	maxHealth = SMaxHealth
	rps=SRps
	hps=SHps
	rangeLevel=SCurrentRange
	health = maxHealth
	active=0
	sellValue = 3
	#set_price_values()
	self.get_node("TimerNode/AttackTimer/Timer").wait_time = (1.0/rps)
	self.get_node("HealthComponent/healthBar").setup()
	
#func set_price_values():
	#for i in range(1,4):
		#get_node("UpgradeNode/Panel/HBox/Upgrade" +str(i) + "/p").text= str(5)
	#pass
	
func _physics_process(_delta):
	if is_instance_valid(target):
		self.look_at(target.position)
	#else:
		#for i in get_node("BulletContainer").get_child_count():
			#get_node("BulletContainer").get_child(i).queue_free()
	pass
			
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

func _attack_anim_timeout():
	get_node("Tower/Area").visible=false
	print("attack done")
	
#attacks enemies
func attack_enemy_in_sight():
	#var tempArray = []
	
	currTargets = get_node("Tower").get_overlapping_bodies()
	
	if currTargets.size()==0:
		active=0
		self.get_node("TimerNode/AttackTimer/Timer").stop()
		return
			
	else:
		get_node("Tower/Area").visible=true
		self.get_node("TimerNode/AttackPeriod").start()
		for i in currTargets:
			i.health -= damage
		
		


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
	
#Level up damage
@warning_ignore("unused_parameter")
func _on_upgrade_1_pressed(_path):
	var pPath = "UpgradeNode/Panel/HBox/Upgrade1/p"
	var price = int(self.get_node(pPath).text)
	if(canBuy(price)):
		damage = damage * 1.5
		Global.currency -= price
		update_sell_value(price)
		get_node(pPath).text = str(price*2)
	else:
		print("Nope, not enough money")

#Level up Range
func _on_upgrade_2_pressed(_path):
	var pPath = "UpgradeNode/Panel/HBox/Upgrade2/p"
	var price = int(self.get_node(pPath).text)
	if(canBuy(price)):
		rangeLevel += 0.10
		self.get_node("Tower/Collision").scale = Vector2(rangeLevel,rangeLevel)
		self.get_node("Tower/Area").scale = Vector2(rangeLevel,rangeLevel)
		self.get_node("Tower/AreaUpgraded").scale = Vector2(rangeLevel+0.10,rangeLevel+0.10)
		Global.currency -= price
		update_sell_value(price)
		get_node(pPath).text = str(price*2)
		get_node("Tower/AreaUpgraded").visible=false
	else:
		print("Nope, not enough money")
	
	
#Level up rps
func _on_upgrade_3_pressed(_path):
	var pPath = "UpgradeNode/Panel/HBox/Upgrade3/p"
	var price = int(self.get_node(pPath).text)
	if(canBuy(price)):
		rps+=0.25
		self.get_node("TimerNode/AttackTimer/Timer").wait_time = (1.0/rps)
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
	get_node("Tower/AreaUpgraded").visible=true
	


func _on_upgrade_2_mouse_exited():
	get_node("Tower/AreaUpgraded").visible=false

func _on_regen_timer_timeout():
	self.health += hps
	if self.health > self.maxHealth:
		self.health = self.maxHealth
