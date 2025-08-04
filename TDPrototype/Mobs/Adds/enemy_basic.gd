extends CharacterBody2D
class_name BasicEnemy

@export var defaultFallingSpeed = 120.0
@onready var fallingSpeed = defaultFallingSpeed

#TODO implement the oscilation speed
@export var defaultOscilationSpeed = 0
@onready var oscilationSpeed = defaultOscilationSpeed

@export var maxHealth = 10

#Healing per second
@export var hps = 0.0

@export var healthDamage = 5
@export var dropRate = 0.6
@onready var health = maxHealth



var gift = preload("res://Mobs/Drops/Reward.tscn")

func _ready(): 
	get_node("HealthComponent/healthBar").setup()
	
func _process(_delta):
	get_node("HealthComponent/healthBar").global_position = self.global_position + Vector2(-25,-25)
	if health <=0:
		if(randf() < dropRate):
			spawnGift()
		death_effects()	
		self.queue_free()
		
func setup(nMaxHealth,nHps,nFallingSpeed,nDamage,nDropRate):
	self.maxHealth=nMaxHealth
	self.hps= nHps
	self.fallingSpeed= nFallingSpeed
	self.healthDamage= nDamage
	self.dropRate = nDropRate
			
func _physics_process(_delta):
	fall()
	

func fall():
	velocity.y = fallingSpeed
	move_and_slide()	

func spawnGift():
	var g = gift.instantiate()
	g.global_position = self.global_position
	get_parent().get_parent().get_node("Drops").add_child(g) 

#Enemy returns to normal speed after a period of time
func _on_debuff_timer_timeout():
	fallingSpeed = defaultFallingSpeed
	oscilationSpeed = defaultOscilationSpeed
	
func death_effects():
	pass
