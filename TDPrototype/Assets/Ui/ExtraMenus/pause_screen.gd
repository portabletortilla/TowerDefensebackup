extends CanvasLayer

signal unpause()
signal quit_game()
signal main_menu_swap()

func _on_resume_pressed():
	unpause.emit()


func _on_main_menu_pressed():
	main_menu_swap.emit()


func _on_quit_pressed():
	quit_game.emit()
	get_tree().quit()
