extends StaticBody2D

@export var value = 2


func _on_mouse_entered():
	Global.currency += value * Global.presentMult
	self.queue_free()

