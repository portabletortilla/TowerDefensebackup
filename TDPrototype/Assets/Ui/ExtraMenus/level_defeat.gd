extends CanvasLayer


signal retry()
signal main_menu_swap()

func _on_retry_pressed():
	retry.emit()


func _on_main_menu_pressed():
	main_menu_swap.emit()

