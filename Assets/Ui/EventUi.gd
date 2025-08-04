extends CanvasLayer

var timer = 10
var hidecoords
var showcoords
var eventDict= { 0: ["Care Package", "0"],
				 1: ["Drop Rate Up", "0"],
				 2: ["Tower Rps Up", "0"],
				 3: [ "Enemy Mvm Down" , "0"],
				 4: [ "Enemy Atk Down" , "0"],
				 5: [ "Enemy Atk Up" , "10"],
				 6: [ "Enemy Hp Up" , "10"],
				 7: [ "Enemy Speed Up" , "25"],
				 8: [ "Enemy Shield" , "25"],
				 9: [ "Enemy Revive" , "60"]}
signal eventBegin
# Called when the node enters the scene tree for the first time.
func _ready():
	timer= Global.eventNotificationWarningDuration

func setup(start ,end):
	self.hidecoords = start
	self.showcoords = end 
	
func entranceAnimation():
	var tween = create_tween()
	tween.tween_property(self.get_node("Panel"), "position", showcoords, 1.2)

func exitAnimation():		
	var tween = create_tween()
	tween.tween_property(self.get_node("Panel"), "position", hidecoords, 1.2)
	
func beginShow(eventId: int ):
	print("Showing event notif")
	get_node("Timer").start()
	get_node("Panel/HBoxContainer/Time Remaining").text = "10"
	get_node("Panel/Description").text = eventDict[eventId][0]
	get_node("Panel/Reward/Amount").text = eventDict[eventId][1]
	self.show()
	entranceAnimation()
	var aux = int(get_node("Panel/HBoxContainer/Time Remaining").text)
	get_node("Panel/HBoxContainer/Time Remaining").text = str(aux-1)
	if aux -1 <=0:
		exitAnimation()
		get_node("Panel").hide()


func tickDown():
	var aux = int(get_node("Panel/HBoxContainer/Time Remaining").text)
	get_node("Panel/HBoxContainer/Time Remaining").text = str(aux-1)
	if aux -1 <=0:
		exitAnimation()
		get_node("Timer").stop()
		eventBegin.emit()

func fade_out():
	var tween = create_tween()
	tween.tween_property(self.get_node("Panel"), "modulate:a", 0.3, 0.1)

func fade_in():			
	var tween = create_tween()
	tween.tween_property(self.get_node("Panel"), "modulate:a", 0.8, 0.1)

