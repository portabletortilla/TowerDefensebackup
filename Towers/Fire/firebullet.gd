extends CharacterBody2D
var collided= false
var target
var Speed = 400
#setup in tower
var bulletDamage 

func _physics_process(_delta):
	if is_instance_valid(target) :
		if not collided:
			velocity = global_position.direction_to(target.position) * Speed
			self.look_at(target.position)
			move_and_slide()
	else:
		self.queue_free()


func _on_area_2d_body_entered(body):
	if "Enemy" in body.name :
		if body.shielding > 0 :
			body.shielding -= 1
			body.updateShield()
		else:
			body.takeDamage(bulletDamage)
		if body.debuffed==0:	
			body.debuffed = 1
			body.speed = body.defaultFallingSpeed * 0.33
			body.debuff_timer_start()
		explode(body)
		

func explode(enemy):
	get_node("FireBullet").visible = false
	get_node("CollisionShape2D").visible = false
	get_node("Area2D").visible = false
	get_node("LingeringEffect/Fire").global_position = enemy.global_position
	get_node("LingeringEffect/Fire").visible = true
	get_node("CPUParticles2D").emitting=false
	collided=true
	get_node("LingeringFlame").global_position = enemy.global_position 
	get_node("LingeringFlame").global_rotation = 90
	get_node("LingeringFlame").visible= true
	get_node("LingeringEffect/Timers/FireDuration").start()
	get_node("LingeringEffect/Timers/FireTick").start()


func _on_timer_fire_tick():
	var aux = self.get_node("LingeringEffect/Fire").get_overlapping_bodies()
	for i in aux:
		if "Enemy" in i.name:
			if i.shielding > 0 :
				i.shielding -= 1
				i.updateShield()
			else:
				i.takeDamage(bulletDamage * 0.4)


func _on_fire_duration_timeout():
	get_node("LingeringFlame").visible= false
	self.queue_free()
