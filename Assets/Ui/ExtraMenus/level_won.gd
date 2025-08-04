extends CanvasLayer


signal next_level()
signal main_menu_swap()

func updateScore():
	get_node("Panel/Score").text = "Total Score: " + str(Global.totalPlayerScore)

func _on_next_pressed():
	next_level.emit()


func _on_main_menu_pressed():
	main_menu_swap.emit()

