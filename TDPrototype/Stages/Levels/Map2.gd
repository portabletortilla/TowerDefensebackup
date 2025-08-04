extends Node2D

@onready var enemy = preload("res://Mobs/Adds/enemy_basic.tscn")
@onready var gameOver=0
var spawnerX
var spawnerY
var enemyN=4

func _ready():
	var spawner = get_node("EnemySpawnPoint/Marker2D").global_position
	spawnerX=spawner[0]
	spawnerY=spawner[1]
	
func _process(_delta):
	if Input.is_action_pressed("ui_up"):
		print("Spawning Enemy")
		spawn_enemy()
		
func spawn_enemy():
	
	var tempEnemy = enemy.instantiate()
	var path = get_node("Enemies")
	tempEnemy.global_position = RandomPosInSpawnPoint()
	tempEnemy.name = "Enemy A " + str(enemyN)
	enemyN+=1  
	path.add_child(tempEnemy)

func RandomPosInSpawnPoint() -> Vector2 :
	var width = self.get_node("Background").texture.get_width()
	var x = randi_range( -(width/2) , width/2 )
	var y = randi_range(-125,125)
	return Vector2((spawnerX + x),(spawnerY + y))



func _on_body_entered_goal(body):
	if "Enemy" in body.name:
		#TODO add mutex lock in here
		Global.health -= body.healthDamage
		#print(health)
		body.queue_free()
		if Global.health <=0 and gameOver == 0:
			gameOver=1
			game_over()

func game_over():
	print("game_over")			
		

	
