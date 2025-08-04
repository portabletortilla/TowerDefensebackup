extends CanvasLayer

var timer = 5
var hidecoords
var showcoords

func setup():
	self.hidecoords = get_node("RankStart").position
	self.showcoords = get_node("RankEnd").position
	
func showRank(rank):
	#reset the box before attributing rank
	for i in range(5):
		get_node("Panel/HBoxContainer/Star"+str(i+1)).frame=0
		get_node("Panel/HBoxContainer/Star"+str(i+1)).pause()
		
	for i in range(rank):
		get_node("Panel/HBoxContainer/Star"+str(i+1)).play()
		
		
	entranceAnimation()	
	
func entranceAnimation():
	#print("AAAAAAAAAAAAA")
	get_node("Timer").start()
	self.show()
	var tween = create_tween()
	tween.tween_property(self.get_node("Panel"), "position", showcoords, 1.2)

func exitAnimation():		
	var tween = create_tween()
	tween.tween_property(self.get_node("Panel"), "position", hidecoords, 1.2)
		
func fade_out():
	var tween = create_tween()
	tween.tween_property(self.get_node("Panel"), "modulate:a", 0.3, 0.1)

func fade_in():			
	var tween = create_tween()
	tween.tween_property(self.get_node("Panel"), "modulate:a", 0.8, 0.1)
