extends StaticBody2D

@export var value = 2

func _on_mouse_entered():
	if(Global.eventLock != 1 and randf_range(0,1.0) < Global.eventChance):
			Global.eventLock = 1
			get_parent().get_parent().beginEvent()
	Global.currency += value * Global.presentMult
	get_tree().get_root().get_node("SceneHandler/Map"+str(Global.currLevel)).updateScore()
	self.queue_free()

