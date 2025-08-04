extends Panel
class_name TowerPanel
@export var areaPath = "Tower/Area"
@export var towerPath = "res://Towers/Wind/wind_tower.tscn"
@export var baseCost = 5
var currentCost
var tower

var currTile
var blocked = 0

func _ready():
	tower = load(towerPath)
	currentCost = baseCost
func _on_gui_input(event):
	
	var tempTower = tower.instantiate()
	
	if event is InputEventMouseButton and event.button_mask == 1 :
		#"Choosing tower" 
		blocked=0
		add_child(tempTower)
		tempTower.process_mode = Node.PROCESS_MODE_DISABLED
		tempTower.scale = Vector2(0.75,0.75)
		tempTower.global_position = event.global_position + Vector2(0,-20)
	elif event is InputEventMouseMotion and event.button_mask == 1 and blocked != 1:
		#"Dragging Tower" 
		if get_child(1).global_position == null or event.global_position == null:
			print("Null positioning detected for hover event")
			return
		get_child(1).global_position = event.global_position + Vector2(0,-20)
		if canPlace():
			get_child(1).get_node(areaPath).modulate = Color(0,255,0,0.65)
		else:
			get_child(1).get_node(areaPath).modulate = Color(255,0,0,0.65)
	elif event is InputEventMouseButton and event.button_mask == 0 and blocked != 1:
		#"placing Tower"
		if get_child_count()>1:
			#Todo add option to drag tower to selection for cancel
			get_child(1).queue_free()
		
		if(!canPlace()):
			print("Invalid Place for tower")
			return	
		if(!canBuy()):
			print("Tower is too expensive")
			return	
			
		var path = get_tree().get_root().get_node("SceneHandler/Map"+str(Global.currLevel)+"/Towers")
		#print(path)
		tempTower.global_position = event.global_position
		tempTower.get_node(areaPath).hide()
		
		tempTower.get_node("TimerNode/AttackTimer").scale = Vector2(2.0,0.5)
		tempTower.get_node("TimerNode/AttackTimer").global_position = tempTower.global_position + Vector2(-25, 30)
		tempTower.get_node("TimerNode/AttackTimer").show()
		tempTower.get_node("HealthComponent/healthBar").scale = Vector2(2.0,0.5)
		tempTower.get_node("HealthComponent/healthBar").global_position = tempTower.global_position + Vector2(-25, -30)
		#tempTower.get_node("HealthComponent/healthBar").show()
		path.add_child(tempTower)
		
	else:
		if get_child_count()>1:
			blocked = 1
			get_child(1).queue_free()	

func canBuy() ->bool:
	
	if Global.currency < currentCost:
		return false
	else:
		Global.currency -= currentCost
		print("current ammount of resources:" + str(Global.currency))
		return true	

func canPlace() -> bool:
	
	var mapPath = get_tree().get_root().get_node("SceneHandler/Map"+str(Global.currLevel)+"/TileMap")
	var tile = mapPath.local_to_map(get_local_win_pos())
	currTile = mapPath.get_cell_atlas_coords(0,tile,false)
	
	var overlappinTowers = get_child(1).get_node("TowerDetection").get_overlapping_bodies()
	#print(overlappinTowers)
	
	return (currTile == Vector2i(13,2)) and overlappinTowers.size()==0 
	
func get_local_win_pos() ->Vector2 :
	var pos = get_global_mouse_position()
	pos.x -= get_viewport().size[0]/2 
	pos.y -= get_viewport().size[1]/2
	return pos

