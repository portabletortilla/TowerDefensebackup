extends Control
var level = 0

signal start_level()
signal quit_game()
@onready var buttons_vb = %VB

func ready() -> void:
	focus_button()

func _on_start_level_button_pressed() -> void:
	start_level.emit(level)
	hide()

func _on_quit_game_button_pressed() -> void:
	quit_game.emit()

func _on_level_selection_button(i:int) -> void:
	print("Choosing Level " + str(i))
	level = i
	get_node("M/VB/Start").disabled = false

func focus_button() -> void:
	if buttons_vb:
		var button: Button = buttons_vb.get_child(0)
		if button is Button:
			button.grab_focus()
