extends CharacterBody2D
class_name BasicEnemy

@export var healthCoef = 1.0
@export var defenseCoef = 1.0
@export var fRCoef = 1.0
@export var damageCoef = 1.0
@export var speedCoef = 1.0

@export var maxHealth = 10.0
@export var defense = 1.0
@export var fireResistance = 0.0
@export var damage = 5.0
@export var defaultFallingSpeed = 120
var speed
@onready var health = maxHealth
#values to save old stats
var maxHealthBase
var speedBase
var damageBase
@export var alive = true
#Healing per second
@export var hps = 0.0
@export var shielding = 0
@export var revives = 0
@onready var debuffed = 0

@export var oscilationSpeed = 1
@export var initialRotation=0.0
@export var freq = 2
@export var time = 0.0
@export var amp = 2
var startingDirection = 1

var gift = preload("res://Mobs/Drops/Reward.tscn")

func _ready(): 
	get_node("HealthComponent/healthBar").setup()
	
func _process(_delta):
	get_node("HealthComponent/healthBar").global_position = self.global_position + Vector2(-25,-25)
	if health <=0 and alive:
		if(revives > 0):
			revives -=1
			health = maxHealth/2
		else:
			alive = false
			if(randf() < Global.dropRate):
				spawnGift()
			death_effects()	
			
	if(shielding>=1 and not get_node("Bubble").visible):
		get_node("Bubble").show()		

func updateShield():
	if(shielding==0):
		get_node("Bubble").hide()	
			
func setup(newStats):
	self.maxHealthBase = newStats[0] * self.healthCoef
	self.maxHealth = maxHealthBase * Global.enemyHpMultiplier
	 
	self.defense = newStats[1] * self.defenseCoef
	self.fireResistance = newStats[2] * self.fRCoef
	
	self.damageBase = newStats[3] * self.damageCoef
	self.damage = damage * Global.enemyDmgMultiplier
	
	self.speedBase = newStats[4] * self.speedCoef
	self.speed = speedBase * Global.enemySpeedMultiplier
	
	self.revives =  Global.reviveAddition
	self.shielding += Global.shieldAddition
	if randf() < 0.5:
		self.startingDirection = -1
	
	var auxTimer1 =	3.5 * (1.0 - fireResistance)
	var auxTimer2 = 1.5 *(1.0 + fireResistance)
	if auxTimer1 <=0:
		auxTimer1=1	
		
	get_node("Timers/DebuffTimer").wait_time = auxTimer1		
	get_node("Timers/ImmunityTimer").wait_time = auxTimer2
	get_node("Bubble").play()	
			
func _physics_process(_delta: float):
	if(oscilationSpeed == 0):
		fall()
	else:	
		time+= _delta
		rotation = cos(freq*time) * amp/PI + initialRotation
		#print(rotation)
		self.velocity = Vector2(0,1).rotated(rotation * startingDirection) * speed 
		move_and_slide()

func fall():
	velocity.y = speed
	move_and_slide()	

func spawnGift():
	var g = gift.instantiate()
	g.global_position = self.global_position
	get_parent().get_parent().get_node("Drops").add_child(g) 

func debuff_timer_start():
	#print("half speed")
	#print(str(get_node("Timers/DebuffTimer").wait_time))
	get_node("Timers/DebuffTimer").start()
#Enemy returns to normal speed after a period of time
func _on_debuff_timer_timeout():
	#print("normal speed again")
	speed = defaultFallingSpeed
	get_node("Timers/ImmunityTimer").start()

func _on_immunity_timer_timeout():
	#print("can be debuffed again")
	debuffed=0

func takeDamage(dmg):
	var d = dmg - self.defense
	if(d < dmg*0.1):
		d = dmg*0.1
	self.health -= d
		
func death_effects():
	Global.playerScoreP += 0.5
	get_tree().get_root().get_node("SceneHandler/Map"+str(Global.currLevel)).updateScore()
	#print("Green Enemy killed, adding .5 points to score")
	if(Global.eventLock != 1 and randf_range(0,1.0) < Global.eventChance):
		Global.eventLock = 1
		get_parent().get_parent().beginEvent()
	self.queue_free()	

func update_stats(eventId:int):
	match eventId:
		
		3:
			speed = speed * Global.enemySpeedMultiplier 
		4:
			damage= damage * Global.enemyDmgMultiplier
		5:
			damage= damage * Global.enemyDmgMultiplier
		6:
			maxHealth= maxHealth * Global.enemyHpMultiplier
			health = health * Global.enemyHpMultiplier
		
		7:		
			speed = speed * Global.enemySpeedMultiplier
		
		8:
			shielding += 1
		
		9:
			revives = 1	

func resetStats(eventId:int):
	match eventId:
		
		3:
			speed = speedBase	
		4:
			damage=damageBase
		5:
			damage=damageBase
		6:
			maxHealth = maxHealthBase
			if(health > maxHealth):
				health = maxHealth
		7:		
			speed = speedBase
		
		8:
			shielding -=1
		
		9:
			revives = 0		
	
