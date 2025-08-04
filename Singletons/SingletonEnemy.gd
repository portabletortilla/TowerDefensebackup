extends CharacterBody2D

const MaxHealth = 5
var health = MaxHealth

func _process(delta):
	if health <=0:
		self.queue_free()
		
