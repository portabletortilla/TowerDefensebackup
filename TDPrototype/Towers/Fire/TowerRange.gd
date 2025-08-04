extends CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready():
	#hide()
	pass

func _draw():
	var center = Vector2(0,0)
	var radius	= get_parent().get_parent().currentRange
	var color = Color(0,0,1,0.50)
	draw_circle(center,radius,color)
	
