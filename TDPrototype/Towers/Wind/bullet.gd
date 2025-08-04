extends CharacterBody2D

var target
var Speed = 400
#setup in tower
var bulletDamage 

func _physics_process(_delta):
	if is_instance_valid(target):
		velocity = global_position.direction_to(target.position) * Speed
		self.look_at(target.position)
		move_and_slide()
	else:
		self.queue_free()


func _on_area_2d_body_entered(body):
	if "Enemy" in body.name:
		body.health -= bulletDamage
		self.queue_free()
