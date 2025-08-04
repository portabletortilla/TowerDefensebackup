extends Panel

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.3, 2.0)

func fade_in():			
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 2.0)
