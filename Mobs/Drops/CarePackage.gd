extends StaticBody2D

@export var value = 50
@export var health = 6

func _ready():
	get_node("UpgradeNode/Panel").position = self.position

func _on_panel_gui_input(event):
	if event is InputEventMouseButton and event.button_mask == 1 :
		get_node("UpgradeNode/Panel").show()	
	

func _on_health_pressed():
	Global.health += health
	get_tree().get_root().get_node("SceneHandler/Map"+str(Global.currLevel)).updateScore()
	self.queue_free()


func _on_currency_pressed():
	Global.currency += value
	get_tree().get_root().get_node("SceneHandler/Map"+str(Global.currLevel)).updateScore()
	self.queue_free()
