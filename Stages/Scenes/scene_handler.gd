extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_main_menu_start_level(i:int):
	
	if i>0 and i<4:
		#not necessary for now since the menu just gets hidden
		#get_node("Main Menu").queue_free()
		set_global_variables(i)
		var game_scene = load("res://Stages/Levels/Map"+str(i)+".tscn").instantiate()
		game_scene.setup()
		add_child(game_scene)
		Engine.time_scale=1

func set_global_variables(i:int):
	Global.currLevel=i
	Global.health= 20
	Global.currency= 100
	Global.presentMult = 1
	Global.currentRound = 0
	Global.PlayerRank=3
	Global.intensityValue = Global.intensityDict[i-1][Global.currentRound] 
	Global.nRounds=2+i
	Global.sellRatio= Global.srDict[i]
	Global.baseEnemyTemplatesStats=Global.baseEnemyTemplatesStatsAux
	Global.waveLineUp=Global.waveLineUpAux
	Global.playerScoreP=0
	Global.totalPlayerScore=0
	obtainBaseStats()

func obtainBaseStats():
	#sorted alfabetically
	var files = DirAccess.get_files_at("res://Score/")
	if(files.is_empty()) :
		print("Missing expected Score file, shuttting down program...")
		get_tree().quit()
	#print(files)	
	var file = FileAccess.open("res://Score/"+ files[files.size() - 1], FileAccess.READ)
	var content = file.get_as_text()
	var lines = content.split("\n",false)
	
	for i in range(1,len(lines)):
		var aux = lines[i].split(":",false)
		Global.ExpectedScorePerLevel[aux[0]] = float(aux[1])
	return content
	
func updateScoresFile():
	var a = Time.get_datetime_string_from_system()
	var b = a.replace("T","_")
	var c = b.replace("-","_")
	var aux = c.replace(":","_")
	var fileName="res://Score/ScoreSave" + aux + ".txt"
	
	var file = FileAccess.open(fileName, FileAccess.WRITE)
	
	var auxString = "ExpectedScoring:\n"
	for key in Global.ExpectedScorePerLevel.keys():
		auxString= auxString + key+":" + str(Global.ExpectedScorePerLevel[key])+ "\n"
	file.store_string(auxString)
	
func _on_main_menu_quit_game():
	#print("Exiting Game")
	updateScoresFile()
	get_tree().quit()

func _next_level(currMap):
	if is_instance_valid(currMap):
		Global.currLevel+=1
		currMap.queue_free()
		set_global_variables(Global.currLevel)
		var game_scene = load("res://Stages/Levels/Map"+str(Global.currLevel)+".tscn").instantiate()
		add_child(game_scene)
		Engine.time_scale=1

func _retry_level(currMap):
	if is_instance_valid(currMap):
		currMap.queue_free()
		set_global_variables(Global.currLevel)
		var game_scene = load("res://Stages/Levels/Map"+str(Global.currLevel)+".tscn").instantiate()
		add_child(game_scene)
		Engine.time_scale=1
		
func to_main(map):
	if is_instance_valid(map):
		map.queue_free()
		self.get_node("MainMenu").show()
