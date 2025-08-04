extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_main_menu_start_level(i:int):
	
	if i>0 and i<4:
		#not necessary for now since the menu just gets hidden
		#get_node("Main Menu").queue_free()
		
		var game_scene = load("res://Stages/Levels/Map"+str(i)+".tscn").instantiate()
		add_child(game_scene)


func _on_main_menu_quit_game():
	#print("Exiting Game")
	get_tree().quit()

func _next_level(currMap):
	if is_instance_valid(currMap):
		Global.currLevel+=1
		currMap.queue_free()
		var game_scene = load("res://Stages/Levels/Map"+str(Global.currLevel)+".tscn").instantiate()
		add_child(game_scene)

func _retry_level(currMap):
	if is_instance_valid(currMap):
		currMap.queue_free()
		var game_scene = load("res://Stages/Levels/Map"+str(Global.currLevel)+".tscn").instantiate()
		add_child(game_scene)
		
func to_main(map):
	if is_instance_valid(map):
		map.queue_free()
		self.get_node("MainMenu").show()
