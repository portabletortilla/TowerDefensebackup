extends CanvasLayer


signal next_level()
signal main_menu()

func _on_next_pressed():
	next_level.emit()


func _on_main_pressed():
	main_menu.emit()

