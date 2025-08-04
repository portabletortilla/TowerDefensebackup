extends BasicEnemy

@export var explosionDamage = 2 * healthDamage

func death_effects():
	var explosion = get_node("Explosion")
	#Safety net for changes in damage
	explosionDamage = 2 * healthDamage
	explode(explosion)
	
func explode(ex):
	print(ex.get_overlapping_bodies())
	for i in ex.get_overlapping_bodies():
		i.health -= explosionDamage
	#TODO Explosion Animation	
