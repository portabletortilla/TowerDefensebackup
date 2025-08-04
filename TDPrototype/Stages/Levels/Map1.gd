extends Node2D
#List of enemy for respective wave,atributes are [Number Left, Type ,Max health , healing per second , falling speed, damage , droprate 
var Waves = [
			 [ [10,0,10,0.0,120,5,0.6] ],
			 [ [15,0,10,0.1,120,5,0.6],[7,1,13,0.0,125,5,0.8] ],
			 [ [30,0,10,0.1,120,5,0.6],[15,1,13,0.0,125,5,0.8] ]
			]
@onready var enemyBase = preload("res://Mobs/Adds/enemy_basic.tscn")
@onready var enemyFire = preload("res://Mobs/Adds/fire_enemy.tscn")
@onready var gameOver=0

#coordinates for the base spawn
var spawnerX
var spawnerY

#number of enemies between each cluster
var nEnemies=1

#id for each enemy spawned
var idNumber=1

var inGame=0
var eval 

func _ready():
	eval = get_node("EvalInfo")
	var spawner = get_node("EnemySpawnPoint/Marker2D").global_position
	spawnerX=spawner[0]
	spawnerY=spawner[1]
	get_node("TowerSelection").progress_bar_activate()
	Global.nRounds=3
	get_node("TowerSelection").set_n_rounds()
	
func _process(_delta):
	if Input.is_action_pressed("Pause"):
		pause_screen()
		
	if Waves[Global.currentRound-1] == [] and get_node("Enemies").get_child_count()==0 and inGame==1:
		inGame=0
		print("Round ended")
		next_round()	
	
	if Input.is_action_pressed("ui_up"):
		#print("Spawning Enemy")
		spawn_enemy()
		

func spawn_enemy():
	if(nEnemies<=0):
		get_node("EnemyDropTimers/SpawnBurst").stop()
		return
	nEnemies-=1
		
	var enemy = choose_enemy()
	
	if (enemy == null):
		get_node("EnemyDropTimers/SpawnBurst").stop()
		get_node("EnemyDropTimers/SpawnCluster").stop()
		nEnemies =0
		return
		
	#var tempEnemy = enemyBase.instantiate()
	
	enemy.global_position = RandomPosInSpawnPoint()
	var path = get_node("Enemies")
	path.add_child(enemy)

func choose_enemy():
	var currentWave = Waves[Global.currentRound-1]
	#print(currentWave)
	if(currentWave == [] ):
		return null
	var index = randi_range(0,currentWave.size()-1)	
	var enemy = currentWave[index]
	var res= get_enemy_instance(enemy)
	enemy[0] = enemy[0] -1
	if(enemy[0]<=0):
		#print("removing")
		currentWave.remove_at(index)
	#print(res)
	return res

func get_enemy_instance(e):
	var enemy
	match e[1]:
		0:
			enemy= enemyBase.instantiate()
			enemy.name = "Enemy Basic " + str(idNumber)
		1:
			enemy = enemyFire.instantiate()
			enemy.name = "Enemy Fire " +str(idNumber)
	idNumber +=1
	enemy.setup(e[2],e[3],e[4],e[5],e[6])	
	return enemy		
	
func RandomPosInSpawnPoint() -> Vector2 :
	var width = self.get_node("Background").texture.get_width()
	var x = randi_range( -(width/2) , width/2 )
	var y = randi_range(-125,125)
	return Vector2((spawnerX + x),(spawnerY + y))



func _on_body_entered_goal(body):
	
	#TODO add mutex lock in here
	Global.health -= body.healthDamage
	eval.updateDamageTaken(body.healthDamage)
	#print(health)
	body.queue_free()
	if Global.health <=0 and gameOver == 0:
		gameOver=1
		game_over()

func game_over():
	print("game_over")	
	_on_screen_next_level()		
		

func pause_screen():
	#TODO try to make the screen darker besides the menu
	Engine.time_scale = 0
	if self.get_node("TowerSelection")._is_tower_hidden() == false:
		self.get_node("TowerSelection").hide_show()
	self.get_node("PauseScreen").show()	

func unpause_screen():
	Engine.time_scale = 1
	if self.get_node("TowerSelection")._is_tower_hidden() == true:
		self.get_node("TowerSelection").hide_show()
	self.get_node("PauseScreen").hide()
	
func next_round():
	if Global.currentRound== Global.nRounds:
		Engine.time_scale = 0

		self.get_node("LevelWon").show()	
	else:
		#TODO performance calculations and adjustments made here 
		var towerList = obtainAllTowers()
		print("list of towers: " + str(towerList))
		var towersValue = towerList.pop_back()
		var performance = eval.updateAndCalculate(towersValue, towerList)
		print("Player performance:" + str(performance))
		get_node("TowerSelection").progress_bar_activate()

func obtainAllTowers():
	var list = [0,0,0,0,0]
	for i in self.get_node("Towers").get_children():
		list[i.type] += 1
		list[-1] += i.value
	return list
func next_round_start():
	print("Next Round")
	inGame=1
	#time between each small group of enemies
	var clusterTimer = get_node("EnemyDropTimers/SpawnCluster")
	clusterTimer.wait_time = 3.0 + randf_range(0.2 , (Global.nRounds - Global.currentRound) + 0.2)
	clusterTimer.start()
	


func _on_pause_screen_main_menu_swap():
	self.get_parent().to_main(self)


func _on_pause_screen_quit_game():
	self.get_parent()._on_main_menu_quit_game()

func _on_screen_next_level():
	self.get_parent()._next_level(self)
	
func _on_pause_retry_level():	
	self.get_parent()._retry_level(self)


func new_enemy_group_spawn():
	var singleEnemySpawn = get_node("EnemyDropTimers/SpawnBurst")
	nEnemies = 1 + randi_range(0,Global.currentRound)
	singleEnemySpawn.wait_time = randf()
	singleEnemySpawn.start()
