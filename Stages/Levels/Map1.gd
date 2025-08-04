extends Node2D
class_name Levels
#List of enemy for respective wave,atributes are [Number Left, Type ,Max health , healing per second , falling speed, damage , droprate 
@onready var Waves = Global.waveLineUp  
@onready var enemyBase = preload("res://Mobs/Adds/enemy_green.tscn")
@onready var enemyFire = preload("res://Mobs/Adds/fire_enemy.tscn")
@onready var enemyElec = preload("res://Mobs/Adds/elec_enemy.tscn")
@onready var enemyWater = preload("res://Mobs/Adds/water_enemy.tscn")
@onready var gameOver=0

#sell ration or towers, decreases in percentage by 1/5% whenever a tower is sold up to a cap of 50%
#coordinates for the base spawn
var spawnerX
var spawnerY



#number of enemies between each cluster
var nEnemies=1

#id for each enemy spawned
var idNumber=1
var eventId=-1
var inGame=0
var eval 
var eventOccured=0
func setup():
	print("Level " + str(Global.currLevel) + " initiated")
	eval = get_node("Eval")
	var spawner = get_node("EnemySpawnPoint/Marker2D").global_position
	spawnerX=spawner[0]
	spawnerY=spawner[1]
	get_node("TowerSelection").progress_bar_activate()
	get_node("TowerSelection").set_n_rounds()
	get_node("Events/EventNotif").setup(get_node("Events/NotifStart").position , get_node("Events/NotifEnd").position)
	get_node("Rank/RankNotif").setup()
	updateScore()
func _process(_delta):
	if Input.is_action_pressed("Pause"):
		pause_screen()
		
	if Waves[Global.currentRound-1] == [] and get_node("Enemies").get_child_count()==0 and inGame==1:
		inGame=0
		print("round_ended")
		endEvent()
		next_round()	
	
	if Input.is_action_pressed("ui_page_down"):
		#print("Spawning Enemy")
		spawn_enemy()
	if Input.is_action_pressed("ui_right"):
		#speeding things up
		Engine.time_scale +=1
	if Input.is_action_pressed("ui_left"):
		#slowing things down
		Engine.time_scale = 1
		#get_node("Rank/RankNotif").showRank(4)
	
	if Input.is_action_pressed("SecretDefeat"):
		#slowing things down
		Engine.time_scale = 0
		self.get_node("LevelDefeat").show()	
	
	if Input.is_action_pressed("SecretWin"):
		#slowing things down
		Engine.time_scale = 0
		self.get_node("LevelWon").show()	
	
	if Input.is_action_pressed("Event Choice"):
		#print("A pressed")
		if(Global.eventLock != 1):
			Global.eventLock = 1
			beginEvent()	
	if Input.is_action_pressed("EndEvent"):
		#print("A pressed")
		endEvent()	
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
	var currentWave = Waves[Global.currentRound - 1]
	#print(currentWave)
	if(currentWave == [] ):
		return null
	
	var index = randi_range(0,currentWave.size()-1)	
	var enemy = currentWave[index]
	var res= get_enemy_instance(enemy)
	enemy[1] = enemy[1] - 1
	if(enemy[1]<=0):
		#print("removing")
		currentWave.remove_at(index)
	#print(res)
	return res

func get_enemy_instance(e):
	var enemy
	match e[0]:
		1:
			enemy= enemyBase.instantiate()
			enemy.name = "Enemy Green " + str(idNumber)
		2:
			enemy = enemyFire.instantiate()
			enemy.name = "Enemy Fire " +str(idNumber)
		3:
			enemy= enemyElec.instantiate()
			enemy.name = "Enemy Yellow " + str(idNumber)
		4:
			enemy= enemyWater.instantiate()
			enemy.name = "Enemy Blue " + str(idNumber)		
	idNumber +=1
	enemy.setup(Global.baseEnemyTemplatesStats)
	return enemy		
	
func RandomPosInSpawnPoint() -> Vector2 :
	var width = self.get_node("Background").texture.get_width()
	var x = randi_range( -(width/2) , width/2 )
	var y = randi_range(-125,125)
	return Vector2((spawnerX + x),(spawnerY + y))



func _on_body_entered_goal(body):
	
	Global.health -= body.damage
	updateScore()
	#eval.updateDamageTaken(body.damage)
	#print(health)
	body.queue_free()
	if Global.health <=0 and gameOver == 0:
		gameOver=1
		game_over()

func game_over():
	print("game_over")	
	Engine.time_scale = 0
	self.get_node("LevelDefeat").show()		
		

func pause_screen():
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
	if Global.currentRound == Global.nRounds:
		Engine.time_scale = 0
		self.get_node("LevelWon").updateScore()
		self.get_node("LevelWon").show()	
	else:
		Global.PlayerRank = get_node("Eval").calcPerformance(Global.currency,Global.health, get_node("Towers").get_children(), str(Global.currLevel)+"-"+str(Global.currentRound))
		Global.intensityValue= Global.intensityDict[Global.currLevel-1][Global.currentRound]
		get_node("Rank/RankNotif").showRank(Global.PlayerRank)
		
		#print(Global.baseEnemyTemplatesStats,obtainAllTowersInv(),Global.intensityValue,Global.PlayerRank)
		get_node("GAUI").notify(Global.baseEnemyTemplatesStats,obtainAllTowersInv(),Global.intensityValue,Global.PlayerRank)
		#var towerList = obtainAllTowers()
		#print("list of towers: " + str(towerList))
		#var towersValue = towerList.pop_back()
		#var performance = eval.updateAndCalculate(towersValue, towerList)
		#print("Player performance:" + str(performance))
		
#add the value of each tower type
func next_level_loading(packet):
	print(packet)
	get_node("TowerSelection").updateBaseStats(packet)
	var aux = packet.replace("[","")
	aux = aux.replace("]","")
	aux = aux.split(", ")
	var newStats=[]
	for v in range(aux.size()):
		newStats.append(float(aux[v]))
		
	Global.baseEnemyTemplatesStats = newStats
	get_node("TowerSelection").progress_bar_activate()
	
func obtainAllTowersInv():
	var list = [0,0,0,0]
	for i in self.get_node("Towers").get_children():
		list[i.type] += i.value
	return list
	
func next_round_start():
	print("Next Round")
	inGame=1
	if (eventOccured==0):
		Global.eventChance*=2
	else:
		eventOccured=0
		Global.eventChance = Global.baseEventChanceDict[Global.currLevel]	
	#time between each small group of enemies
	var clusterTimer = get_node("EnemyDropTimers/SpawnCluster")
	clusterTimer.wait_time = 3.0 + randf_range(0.1 , (Global.nRounds-Global.currentRound) + 0.1 + (6 - Global.intensityValue)*0.05 )
	clusterTimer.start()	

func updateScore():
	get_node("Eval").updateScore(Global.currency,Global.health, get_node("Towers").get_children())
	get_node("TowerSelection").updateBaseStats(Global.baseEnemyTemplatesStats)
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
	nEnemies = 1 + randi_range(0,Global.currentRound+Global.intensityValue)
	singleEnemySpawn.wait_time = randf()
	singleEnemySpawn.start()

func beginEvent():
	print("Event chance has been triggered...")
	eventOccured=1
	Global.eventChance = Global.baseEventChanceDict[Global.currLevel] + 0.005 * abs(3-Global.intensityValue)
	var aux = get_node("Events").decideEvent()
	eventId = aux[0]
	get_node("Events/EventDuration").wait_time = aux[1]
	self.get_node("Events/EventNotif").beginShow(eventId)
	
func startEvent():
	get_node("Events").event(eventId)
	get_node("Events/EventDuration").start()

func endEvent():
	Global.eventLock = 0
	match eventId:
		0:	
			Global.dropRate = Global.dropRateStagnant
		1:
			Global.rpsMultplier = 1
		2:
			resetTowers()
		_:	
			Global.enemySpeedMultiplier = 1
			Global.enemyDmgMultiplier = 1
			Global.enemyHpMultiplier = 1
			Global.shieldAddition=0
			Global.reviveAddition=0
			
			if(eventId > 2):
				resetEnemies(eventId)

func resetEnemies(eI:int):
	for e in get_node("Enemies").get_children():
		e.resetStats(eI)	

func resetTowers():
	for t in get_node("Towers").get_children():
		t.updateRPS()
